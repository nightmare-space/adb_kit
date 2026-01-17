import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:adb_util/adb_util_flutter.dart';
import 'package:signale/signale.dart';
import 'adb_device.dart';
import 'package:adb_dart/adb_dart.dart';

/// 使用 adb 协议直接连接到设备获取到的设备信息
/// TODO 需要放到别的库，因为当前库是开源的
class AdbDeviceRaw extends AdbDevice {
  AdbDeviceRaw(this.connection, super.serial, super.stat);
  AdbConnection connection;
  late ShellService shellService = ShellService(connection);

  @override
  Future<ShellSession> openShellSession({String? password}) async {
    ADBShellIO adbShellIO = await shellService.interactive();
    final controller = StreamController<Uint8List>(
      onCancel: () {
        adbShellIO.close();
      },
    );
    adbShellIO = await shellService.interactive();
    // String changeSizeCmd = 'stty cols ${interactiveTerminal.viewWidth} rows ${interactiveTerminal.viewHeight}\n';
    adbShellIO.listen(
      (event) {
        controller.add(utf8.encode(event));
      },
      onError: (e) {
        controller.addError(e);
      },
      onDone: () {
        controller.close();
      },
    );
    return ShellSession(
      output: controller.stream,
      write: (data) {
        adbShellIO.write(utf8.decode(data));
      },
      close: () {
        adbShellIO.close();
        controller.close();
      },
    );
  }

  @override
  Future<String> runShell(String cmd, {String? password}) async {
    return await shellService.exec(cmd);
  }

  @override
  Future<bool> pushFile({
    required String sourcePath,
    required String targetPath,
    String? password,
  }) async {
    final sync = SyncService(connection);
    try {
      SyncPushResult result = await sync.pushFile(
        sourcePath,
        targetPath,
        onProgress: (int sent, int total) {
          Log.i('Push progress: $sent / $total');
        },
      );
      // ${result.speedText}
      Log.i('Push file succeeded: ${result.speedText}.');
      return true;
    } catch (e) {
      Log.e('Push file failed: $e');
      rethrow;
    }
  }

  @override
  Future<bool> forwardTcpToService({required int localPort, required String remoteService}) async {
    try {
      final forward = ForwardService(connection);
      ForwardHandle forwardHandle = await forward.forwardTcpToService(
        localPort: localPort,
        remoteService: remoteService,
      );
      Log.i('forwarded success 127.0.0.1:$localPort -> $remoteService');
      return true;
    } catch (e) {
      Log.e('forwarded error: $e');
      return false;
    }
  }

  // 需要实现 adb install -t xxx.apk
  @override
  Future<bool> installApk({required String apkPath, String? password}) async {
    try {
      String data = await execWL(
        [adb, '-s', serial, 'install', '-t', apkPath],
        password: password,
      );
      Log.i('installResult -> $data');
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
