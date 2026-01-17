import 'dart:async';
import 'dart:typed_data';
import 'package:adb_util/src/adb.dart';
import 'package:adb_util/src/foundation/adb_foundation.dart';
import 'package:signale/signale.dart';
import 'adb_device.dart';
import 'package:adb_dart/adb_dart.dart';
import 'package:flutter_pty/flutter_pty.dart';

/// 从 adb 命令获取到的设备信息
class AdbDeviceBinary extends AdbDevice {
  AdbDeviceBinary(super.serial, super.stat);
  static AdbDeviceBinary parse(String data) {
    final tmp = data.trim().split(RegExp('\\s+'));
    final device = AdbDeviceBinary(tmp.first, tmp.last);
    return device;
  }

  @override
  Future<ShellSession> openShellSession({String? password}) async {
    // TODO: windows
    // adbShell = Pty.start(
    //   'cmd',
    //   arguments: ['/C', 'adb', '-s', widget.device.serial, 'shell'],
    //   environment: envir(),
    //   workingDirectory: '/',
    // );
    late Pty pty = Pty.start(
      adb,
      arguments: ['-s', serial, 'shell'],
      environment: adbEnvir(),
      workingDirectory: '/',
    );

    final controller = StreamController<Uint8List>(
      onCancel: () {
        Log.i('pty kill');
        pty.kill();
      },
    );
    pty.output.listen(
      controller.add,
      onError: controller.addError,
      onDone: controller.close,
    );

    return ShellSession(
      output: controller.stream,
      write: pty.write,
      close: () {
        pty.kill();
        controller.close();
      },
    );
  }

  @override
  Future<String> runShell(String cmd, {String? password}) async {
    String data = await execWL(
      [adb, '-s', serial, 'shell', cmd],
      password: password,
    );
    return data;
  }

  @override
  Future<bool> forwardTcpToService({required int localPort, required String remoteService}) async {
    // 27183 -> 27199 是 scrcpy 用的端口范围
    String cmd = '$adb -s $serial forward tcp:$localPort $remoteService';
    Log.i('cmd -> $cmd');
    await exec(cmd, useProcessRun: true);
    return true;
  }

  @override
  Future<bool> installApk({required String apkPath, String? password}) async {
    // push file and install apk using pm install
    String apkName = apkPath.split('/').last;
    bool pushed = await pushFile(
      sourcePath: apkPath,
      targetPath: '/data/local/tmp/$apkName',
      password: password,
    );
    if (!pushed) {
      return false;
    }
    String installResult = await runShell(
      'pm install -t /data/local/tmp/$apkName',
      password: password,
    );
    Log.i('installResult -> $installResult');
    if (installResult.contains('Failure')) {
      return false;
    }
    return true;
  }

  @override
  Future<bool> pushFile({required String sourcePath, required String targetPath, String? password}) async {
    try {
      // -s 192.168.31.110:5555 push /Users/nightmare/Downloads/shizuku-v13.5.4.r1049.0e53409-release (4).apk /storage/emulated/0/shizuku-v13.5.4.r1049.0e53409-release (4).apk
      // TODO 上面这个名称挂了
      String result = await execWL(
        [adb, '-s', serial, 'push', sourcePath, targetPath],
        password: password,
      );
      return result.contains('file pushed');
    } catch (e) {
      // 有的 adb push 成功也是往 error 写的
      if ('$e'.contains('1 file pushed')) {
        return true;
      }
      rethrow;
    }
  }
}
