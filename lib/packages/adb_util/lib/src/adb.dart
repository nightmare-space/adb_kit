import 'dart:async';
import 'dart:isolate';
import 'package:global_repository/global_repository_dart.dart' hide exec;
import 'package:signale/signale.dart';
import 'adb_foundation.dart';
import 'foundation/adb_device.dart';
import 'foundation/adb_exception.dart';
import 'foundation/adb_connect_result.dart';

String adb = 'adb';

bool _isPooling = false;

String shortHash(Object? object) {
  return object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
}

Map<String, String> modelCache = {};
Map<String, String> deviceIDCache = {};
Future<String?> getDeviceID(
  String serial, {
  String? password,
}) async {
  if (deviceIDCache.containsKey(serial)) {
    return deviceIDCache[serial];
  }
  String nidPath = '/data/local/tmp/nid';
  String cmd = '$adb -s $serial shell cat $nidPath';
  String? id;
  try {
    id = await exec(cmd, password: password);
  } catch (e) {
    Log.i('cat nid failed : $e try write a new one and get again');
    try {
      await writeKey(serial, password);
      id = await exec(cmd, password: password);
    } catch (e, stackTrace) {
      Log.e("important error -> $e $stackTrace");
    }
  }
  deviceIDCache[serial] = id ?? 'unknown';
  return deviceIDCache[serial];
}

Future<void> writeKey(String serial, String? password) async {
  String nidPath = '/data/local/tmp/nid';
  String id = shortHash(() {}).toString();
  await execWL(
    [adb, '-s', serial, 'shell', 'echo $id > $nidPath'],
    password: password,
  );
  // TODO 下面代码在 Linux/Mac 正常，在 Windows 崩了
  // String test = await exec('$adb -s $serial shell echo $id', password: password);
  // Log.e('test -> $test');
}

Future<String?> getDeviceProductModel(
  String serial, {
  String? password,
}) async {
  if (modelCache.containsKey(serial)) {
    // Log.i('get model from cache');
    return modelCache[serial]!;
  }
  String getPropPrefix = '$adb -s $serial shell getprop';
  String? model;
  // Some device like xiaomi can't get model name by `ro.product.marketname`
  try {
    model = await exec('$getPropPrefix ro.product.marketname', password: password);
    if (model.trim().isEmpty) {
      model = await exec('$getPropPrefix ro.product.model', password: password);
    }
    modelCache[serial] = model;
  } catch (e) {
    rethrow;
  }
  return model;
}

typedef ADBResultCallback = void Function(List<ADBDevice> data);

class ADB {
  static final List<ADBResultCallback> _callback = [];
  static late Isolate isolate;
  static String? _libPath;
  static String? _password;
  static Future<void> reconnectDevices(String ip, [String? port]) async {
    await disconnectDevice(ip);
    connectDevices(ip);
  }

  static Future<void> setDevicePassword(String password) async {
    _password = password;
  }

  /// 给安卓用的，设置so库的位置
  static void setLibraryPath(String? path) {
    _libPath = path;
  }

  static void addListener(ADBResultCallback listener) {
    _callback.add(listener);
  }

  static void removeListener(ADBResultCallback listener) {
    if (_callback.contains(listener)) {
      _callback.remove(listener);
    }
  }

  static void _notifiAll(List<ADBDevice> data) {
    for (ADBResultCallback call in _callback) {
      call(data);
    }
  }

  static Future<void> handleResult(String? data) async {
    if (data!.startsWith('List of devices')) {
      final List<String> outList = data.split('\n');
      // 删除 `List of devices attached`
      // Rmove `List of devices attached`
      outList.removeAt(0);
      final List<ADBDevice> tmpDevices = [];
      for (final String str in outList) {
        final ADBDevice device = ADBDevice.parse(str);
        if (!device.isConnect) {
          continue;
        }
        String? model;
        String? nid;
        try {
          model = await getDeviceProductModel(device.serial, password: _password);
          nid = await getDeviceID(device.serial, password: _password);
        } catch (e) {
          continue;
        }
        device.productModel = model;
        device.nid = nid!;
        device.password = _password;
        tmpDevices.add(device);
      }
      _notifiAll(tmpDevices);
    }
  }

  static Future<void> startPoolingListDevices({
    Duration duration = const Duration(milliseconds: 600),
  }) async {
    if (_isPooling) {
      return;
    }
    _isPooling = true;
    SendPort? sendPort;
    final ReceivePort receivePort = ReceivePort();
    receivePort.listen((dynamic msg) {
      if (sendPort == null) {
        sendPort = msg as SendPort?;
      } else {
        handleResult(msg);
        // Log.e('Isolate Message -> $msg');
      }
    });
    isolate = await Isolate.spawn(
      adbPollingIsolate,
      IsolateArgs(
        duration,
        receivePort.sendPort,
        RuntimeEnvir.packageName,
        _libPath,
      ),
    );
  }

  static Future<void> stopPoolingListDevices() async {
    if (!_isPooling) {
      return;
    }
    _isPooling = false;
    isolate.kill(priority: Isolate.immediate);
  }

  static Future<ADBConnectResult> connectDevices(String ipAndPort) async {
    String cmd = '$adb connect $ipAndPort';
    if (ipAndPort.contains(' ')) {
      cmd = '$adb pair ${ipAndPort.split(' ').first} ${ipAndPort.split(' ').last}';
    }
    final String result = await exec(cmd, useProcessRun: true);
    Log.i('connect devices result -> $result');
    if (result.contains('failed to authenticate')) {
      throw NeedAuthenticate();
      // TODO windows cannot connect
    } else if (result.contains(RegExp('Connection refused'))) {
      // TODO
      // throw Exception('$ipAndPort 无法连接，对方可能未打开网络ADB调试');
      throw ConnectRefused();
    } else if (result.contains('already connected')) {
      // TODO 这里需要处理 offline 的时候
      throw AlreadyConnected();
    } else if (result.contains('connect')) {
      // return ADBResult('连接成功');
      return SuccessConnect();
    } else if (result.contains('Successfully paired')) {
      // return ADBResult('配对成功，还需要连接一次');
      return SuccessPair();
    }
    return ADBConnectResult(result);
    //todo timed out
  }

  static Future<String> disconnectDevice(String ipAndPort) async {
    return await exec('$adb disconnect $ipAndPort', useProcessRun: true);
  }
}

class IsolateArgs {
  final Duration duration;
  final SendPort sendPort;
  final String? package;
  // for android
  final String? libPath;
  IsolateArgs(this.duration, this.sendPort, this.package, this.libPath);
}

// 新isolate的入口函数
Future<void> adbPollingIsolate(IsolateArgs args) async {
  // 实例化一个ReceivePort 以接收消息
  final ReceivePort receivePort = ReceivePort();
  RuntimeEnvir.initEnvirWithPackageName(args.package!);
  if (args.libPath != null) {
    RuntimeEnvir.put("PATH", '${args.libPath!}:${RuntimeEnvir.path}');
  }
  // 把它的sendPort发送给宿主isolate，以便宿主可以给它发送消息
  args.sendPort.send(receivePort.sendPort);
  Timer.periodic(args.duration, (timer) async {
    try {
      String result = await exec('adb devices', useProcessRun: true);
      args.sendPort.send(result);
    } catch (e) {
      Log.e('ADB polling error : ${e.toString()}');
    }
  });
}
