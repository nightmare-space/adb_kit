library adbutil;

import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:global_repository/global_repository.dart';

import 'foundation/exception.dart';

export 'foundation/exception.dart';

class AdbResult {
  AdbResult(this.message);

  final String message;
}

class Arg {
  final String package;
  final String cmd;

  Arg(this.package, this.cmd);
}

Future<String> asyncExec(String cmd) async {
  if (kDebugMode) {
    return execCmd(cmd);
  }
  return await compute(execCmdForIsolate, Arg(RuntimeEnvir.packageName, cmd));
}

Map<String, String> adbEnvir() {
  Map<String, String> envir = RuntimeEnvir.envir();
  envir['TMPDIR'] = RuntimeEnvir.binPath;
  envir['HOME'] = RuntimeEnvir.binPath;
  envir['LD_LIBRARY_PATH'] = RuntimeEnvir.binPath;
  return envir;
}

Future<String> execCmdForIsolate(
  Arg arg, {
  bool throwException = true,
}) async {
  RuntimeEnvir.initEnvirWithPackageName(arg.package);
  final List<String> args = arg.cmd.split(' ');
  ProcessResult execResult;
  if (Platform.isWindows) {
    Log.e(RuntimeEnvir.envir()['PATH']);
    execResult = await Process.run(
      args[0],
      args.sublist(1),
      environment: RuntimeEnvir.envir(),
      includeParentEnvironment: true,
      runInShell: true,
    );
  } else {
    execResult = await Process.run(
      args[0],
      args.sublist(1),
      environment: adbEnvir(),
      includeParentEnvironment: true,
      runInShell: false,
    );
  }
  if ('${execResult.stderr}'.isNotEmpty) {
    if (throwException) {
      Log.w('adb stderr -> ${execResult.stderr}');
    }
  }
  // Log.e('adb stdout -> ${execResult.stdout}');
  return execResult.stdout.toString().trim();
}

Future<String> execCmd(
  String cmd, {
  bool throwException = true,
}) async {
  final List<String> args = cmd.split(' ');
  ProcessResult execResult;
  if (Platform.isWindows) {
    execResult = await Process.run(
      args[0],
      args.sublist(1),
      environment: RuntimeEnvir.envir(),
      includeParentEnvironment: true,
      runInShell: true,
    );
  } else {
    execResult = await Process.run(
      args[0],
      args.sublist(1),
      environment: adbEnvir(),
      includeParentEnvironment: true,
      runInShell: false,
    );
  }
  if ('${execResult.stderr}'.isNotEmpty) {
    if (throwException) {
      // Log.w('adb stderr -> ${execResult.stderr}');
      throw Exception(execResult.stderr);
    }
  }
  // Log.e('adb stdout -> ${execResult.stdout}');
  return execResult.stdout.toString().trim();
}

// 单纯的依靠split(' ')在一些带空格的参数下会出错
// 例如参数是路径，路径指向的文件夹有空格
Future<String> execCmd2(List<String> args) async {
  ProcessResult execResult;
  if (Platform.isWindows) {
    execResult = await Process.run(
      args[0],
      args.sublist(1),
      environment: RuntimeEnvir.envir(),
      includeParentEnvironment: true,
      runInShell: true,
    );
  } else {
    execResult = await Process.run(
      args[0],
      args.sublist(1),
      environment: adbEnvir(),
      includeParentEnvironment: true,
      runInShell: false,
    );
  }
  if ('${execResult.stderr}'.isNotEmpty) {
    // Log.w('adb stderr -> ${execResult.stderr}');
    throw Exception(execResult.stderr);
  }
  // Log.e('adb stdout -> ${execResult.stdout}');
  return execResult.stdout.toString().trim();
}

bool _isPooling = false;

typedef ResultCall = void Function(String data);

class AdbUtil {
  static final List<ResultCall> _callback = [];
  static Isolate isolate;
  static Future<void> reconnectDevices(String ip, [String port]) async {
    await disconnectDevices(ip);
    connectDevices(ip);
  }

  static void addListener(ResultCall listener) {
    _callback.add(listener);
  }

  static void removeListener(ResultCall listener) {
    if (_callback.contains(listener)) {
      _callback.remove(listener);
    }
  }

  static void _notifiAll(String data) {
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
    SendPort sendPort;
    final ReceivePort receivePort = ReceivePort();
    receivePort.listen((dynamic msg) {
      if (sendPort == null) {
        sendPort = msg as SendPort;
      } else {
        _notifiAll(msg);
        // Log.e('Isolate Message -> $msg');
      }
    });
    isolate = await Isolate.spawn(
      adbPollingIsolate,
      IsolateArgs(duration, receivePort.sendPort, RuntimeEnvir.packageName),
    );
  }

  static Future<void> stopPoolingListDevices() async {
    if (!_isPooling) {
      return;
    }
    _isPooling = false;
    isolate.kill(priority: Isolate.immediate);
  }

  static Future<AdbResult> connectDevices(String ipAndPort) async {
    String cmd = 'adb connect $ipAndPort';
    if (ipAndPort.contains(' ')) {
      cmd =
          'adb pair ${ipAndPort.split(' ').first} ${ipAndPort.split(' ').last}';
    }
    // ProcessResult resulta = await Process.run(
    //   'adb',
    //   ['pair', '192.168.237.156:40351', '723966'],
    //   environment: PlatformUtil.environment(),
    //   includeParentEnvironment: true,
    //   // runInShell: true,
    // );
    // Log.d(resulta.stdout);
    // Log.e(resulta.stderr);
    final String result = await execCmd(cmd);
    if (result.contains(RegExp('refused|failed'))) {
      throw ConnectFail('$ipAndPort 无法连接，对方可能未打开网络ADB调试');
    } else if (result.contains('already connected')) {
      throw AlreadyConnect('该设备已连接');
    } else if (result.contains('connect')) {
      return AdbResult('连接成功');
    } else if (result.contains('Successfully paired')) {
      return AdbResult('配对成功，还需要连接一次');
    }
    return AdbResult(result);
    //todo timed out
  }

  static Future<void> disconnectDevices(String ipAndPort) async {
    final String result = await execCmd('adb disconnect $ipAndPort');
  }

  static Future<int> getForwardPort(
    String serial, {
    int rangeStart = 27183,
    int rangeEnd = 27199,
    String targetArg = 'localabstract:scrcpy',
  }) async {
    while (rangeStart != rangeEnd) {
      try {
        await execCmd(
          'adb -s $serial forward tcp:$rangeStart $targetArg',
          throwException: false,
        );
        Log.d('端口$rangeStart绑定成功');
        return rangeStart;
      } catch (e) {
        Log.w('端口$rangeStart绑定失败');
        rangeStart++;
      }
    }
    return null;
  }

  static Future<bool> pushFile(
    String serial,
    String filePath,
    String pushPath,
  ) async {
    try {
      String data = await execCmd2([
        'adb',
        '-s',
        serial,
        'push',
        filePath,
        pushPath,
      ]);
      Log.d('PushFile log -> $data');
      return true;
    } catch (e) {
      Log.e('PushFile error -> $pushFile');
      return false;
    }
  }
}

class IsolateArgs {
  final Duration duration;
  final SendPort sendPort;
  final String package;

  IsolateArgs(this.duration, this.sendPort, this.package);
}

// 新isolate的入口函数
Future<void> adbPollingIsolate(IsolateArgs args) async {
  // 实例化一个ReceivePort 以接收消息
  final ReceivePort receivePort = ReceivePort();
  RuntimeEnvir.initEnvirWithPackageName(args.package);
  // 把它的sendPort发送给宿主isolate，以便宿主可以给它发送消息
  args.sendPort.send(receivePort.sendPort);
  final Timer timer = Timer.periodic(args.duration, (timer) async {
    try {
      String result = await execCmd('adb devices');
      args.sendPort.send(result);
    } catch (e) {
      Log.i('ADB polling error : ${e.toString()}');
    }
  });
}
