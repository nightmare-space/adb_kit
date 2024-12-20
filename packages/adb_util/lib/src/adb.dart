import 'dart:async';
import 'dart:isolate';
import 'package:global_repository/global_repository_dart.dart';
import 'package:signale/signale.dart';

String adb = 'adb';

class ADBResult {
  ADBResult(this.message);

  final String message;
}

bool _isPooling = false;

typedef ResultCall = void Function(String? data);

class ADB {
  static final List<ResultCall> _callback = [];
  static late Isolate isolate;
  static String? _libPath;
  static Future<void> reconnectDevices(String ip, [String? port]) async {
    await disconnectDevices(ip);
    connectDevices(ip);
  }

  /// 给安卓用的，设置so库的位置
  static void setLibraryPath(String? path) {
    _libPath = path;
  }

  static void addListener(ResultCall listener) {
    _callback.add(listener);
  }

  static void removeListener(ResultCall listener) {
    if (_callback.contains(listener)) {
      _callback.remove(listener);
    }
  }

  static void _notifiAll(String? data) {
    for (ResultCall call in _callback) {
      call(data);
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
        _notifiAll(msg);
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
    final String result = await exec(cmd);
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
    final String result = await exec('adb disconnect $ipAndPort');
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
    RuntimeEnvir.put("PATH", args.libPath! + ':' + RuntimeEnvir.path!);
  }
  // 把它的sendPort发送给宿主isolate，以便宿主可以给它发送消息
  args.sendPort.send(receivePort.sendPort);
  final Timer timer = Timer.periodic(args.duration, (timer) async {
    try {
      String result = await exec('adb devices');
      args.sendPort.send(result);
    } catch (e) {
      Log.e('ADB polling error : ${e.toString()}');
    }
  });
}
