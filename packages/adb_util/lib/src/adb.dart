import 'dart:async';
import 'dart:isolate';
import 'package:global_repository/global_repository_dart.dart' hide exec;
import 'package:signale/signale.dart';

import 'adb_foundation.dart';

String adb = 'adb';

class ADBResult {
  ADBResult(this.message);

  final String message;

  @override
  String toString() {
    return message;
  }
}

bool _isPooling = false;

class ADBDevice {
  ADBDevice(this.serial, this.stat);
  static ADBDevice parse(String data) {
    final tmp = data.trim().split(RegExp('\\s+'));
    final device = ADBDevice(tmp.first, tmp.last);
    return device;
  }

  /// ip or serial
  final String serial;

  /// ro.product.model or ro.product.marketname(xiaomi)
  String? productModel;

  /// connect stat
  String stat;

  /// /data/local/tmp/nid
  String nid = '';

  /// 判断 serial 是否是 ipv4/ipv6
  /// check serial is ipv4/ipv6
  bool get isNetworkDevice {
    return serial.contains(':');
  }

  /// [240e:39c:3f:7300:278f:fd9a:c63f:cd1c]:5555
  String extractIp() {
    // 正则表达式匹配IPv6地址
    final ipv6RegExp = RegExp(r'([a-fA-F0-9:]+:+)+[a-fA-F0-9]+');
    // 正则表达式匹配IPv4地址
    final ipv4RegExp = RegExp(r'(\d{1,3}\.){3}\d{1,3}');

    // 尝试匹配IPv6地址
    final ipv6Match = ipv6RegExp.firstMatch(serial);
    if (ipv6Match != null) {
      return '[${ipv6Match.group(0)!}]';
    }

    // 尝试匹配IPv4地址
    final ipv4Match = ipv4RegExp.firstMatch(serial);
    if (ipv4Match != null) {
      return ipv4Match.group(0)!;
    }

    throw Exception('无法匹配到IP地址');
  }

  String extractPort() {
    return serial.split(':').last;
  }

  bool get isConnect => stat == 'device';

  String? password;

  @override
  String toString() {
    return 'ADBDevice{serial: $serial, stat: $stat model: $productModel nid: $nid}';
  }

  @override
  bool operator ==(Object other) {
    if (other is ADBDevice) {
      return other.serial == serial;
    }
    return false;
  }

  @override
  int get hashCode => serial.hashCode;
}

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
    await writeKey(serial, password!);
    id = await exec(cmd, password: password);
  }
  // if (id.contains('No such file')) {
  // }
  deviceIDCache[serial] = id;
  return id;
}

Future<void> writeKey(String serial, String password) async {
  String nidPath = '/data/local/tmp/nid';
  String id = shortHash(() {}).toString();
  await exec('$adb -s $serial shell echo $id > $nidPath', password: password);
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
    await disconnectDevices(ip);
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

  static Future<ADBResult> connectDevices(String ipAndPort) async {
    String cmd = 'adb connect $ipAndPort';
    if (ipAndPort.contains(' ')) {
      cmd = 'adb pair ${ipAndPort.split(' ').first} ${ipAndPort.split(' ').last}';
    }
    final String result = await exec(cmd, useProcessRun: true);
    Log.i('connectDevices result -> $result');
    if (result.contains(RegExp('refused|failed'))) {
      throw Exception('$ipAndPort 无法连接，对方可能未打开网络ADB调试');
    } else if (result.contains('already connected')) {
      throw Exception('该设备已连接');
    } else if (result.contains('connect')) {
      return ADBResult('连接成功');
    } else if (result.contains('Successfully paired')) {
      return ADBResult('配对成功，还需要连接一次');
    }
    return ADBResult(result);
    //todo timed out
  }

  static Future<void> disconnectDevices(String ipAndPort) async {
    await exec('adb disconnect $ipAndPort');
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
