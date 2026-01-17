import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:adb_util/src/device/adb_device.dart';
import 'package:global_repository/global_repository_dart.dart' hide exec;
import 'package:signale/signale.dart';
import 'foundation/adb_foundation.dart';
import 'device/adb_device_binary.dart';
import 'extension/adb_device_ext.dart';
import 'foundation/adb_exception.dart';

String adb = 'adb';

bool _isPooling = false;

String shortHash(Object? object) {
  return object.hashCode.toUnsigned(20).toRadixString(16).padLeft(5, '0');
}

Map<String, String> modelCache = {};
Map<String, String> deviceIDCache = {};

typedef AdbResultCallback = void Function(List<AdbDevice> data);

class AdbBinary {
  static final List<AdbResultCallback> _callback = [];
  static late Isolate isolate;
  static String? _libPath;
  static String? _password;
  static Future<void> reconnectDevices(String ip, [String? port]) async {
    await disconnectDevice(ip);
    connectDevice(ip);
  }

  static Future<void> setDevicePassword(String? password) async {
    _password = password;
  }

  /// 给安卓用的，设置so库的位置
  /// 目前没用了，之前是动态编译才用的
  @Deprecated('useless')
  static void setLibraryPath(String? path) {
    _libPath = path;
  }

  static void addListener(AdbResultCallback listener) {
    _callback.add(listener);
  }

  static void removeListener(AdbResultCallback listener) {
    if (_callback.contains(listener)) {
      _callback.remove(listener);
    }
  }

  static void _notifiAll(List<AdbDevice> data) {
    for (AdbResultCallback call in _callback) {
      call(data);
    }
  }

  static Future<void> handleResult(
    String? data, {
    void Function(String)? onError,
  }) async {
    if (data!.startsWith('List of devices')) {
      final List<String> outList = data.split('\n');
      // 删除 `List of devices attached`
      // Rmove `List of devices attached`
      outList.removeAt(0);
      final List<AdbDeviceBinary> tmpDevices = [];
      for (final String str in outList) {
        final AdbDeviceBinary device = AdbDeviceBinary.parse(str);
        if (!device.isConnect) {
          continue;
        }
        String? model;
        String? uid;
        try {
          model = await device.getDeviceProductModel(password: _password);
          uid = await device.getDeviceUniqueID(password: _password);
        } catch (e) {
          onError?.call(e.toString());
          continue;
        }
        device.productModel = model;
        device.uid = uid!;
        // TODO
        device.password = _password ?? '';
        tmpDevices.add(device);
      }
      _notifiAll(tmpDevices);
    }
  }

  /// 开始轮询列出设备
  static Future<void> startPoolingListDevices({
    Duration duration = const Duration(milliseconds: 600),
    void Function(String)? onError,
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
        handleResult(msg, onError: onError);
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

  static Future<bool> connectDevice(String ipAndPort) async {
    String cmd = '$adb connect $ipAndPort';
    final String result = await exec(cmd, useProcessRun: true);
    Log.v('connect devices result -> $result');
    // failed to connect to '240e:452:de06:478a:2763:981e:d0a5:fe4f:5555': Network is unreachabl
    if (result.contains('failed to authenticate')) {
      throw NeedAuthenticate();
      // TODO windows cannot connect
    } else if (result.contains(RegExp('Connection refused'))) {
      throw ConnectRefused();
    } else if (result.contains('already connected')) {
      // TODO 这里需要处理 offline 的时候
      throw AlreadyConnected();
    } else if (result.contains('connect')) {
      return true;
    }
    return false;
  }

  static Future<bool> pairDevice(String ipAndPort, String pairCode) async {
    String cmd = '$adb pair $ipAndPort $pairCode';
    final String result = await exec(cmd, useProcessRun: true);
    Log.v('pair devices result -> $result');
    if (result.contains('Successfully paired')) {
      return true;
    }
    return false;
  }

  static Future<bool> disconnectDevice(String ipAndPort) async {
    String result = await exec('$adb disconnect $ipAndPort', useProcessRun: true);
    return result.contains('disconnected');
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
  if (Platform.isIOS) {
    return;
  }
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
