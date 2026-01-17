import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';
import 'package:adb_util/adb_util_flutter.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:global_repository/global_repository_dart.dart' hide exec;

/// 包装一个可以监听流，可以写入数据，可以关闭的shell会话
class ShellSession {
  final Stream<Uint8List> output;
  final void Function(Uint8List data) write;
  final void Function() close;

  ShellSession({
    required this.output,
    required this.write,
    required this.close,
  });
}

mixin AdbDeviceAbility {
  /// 在目标设备上运行 shell 命令
  Future<String> runShell(String cmd, {String? password});

  /// 打开一个交互式的 shell 会话
  Future<ShellSession> openShellSession({String? password});

  /// 推送文件到目标设备
  Future<bool> pushFile({
    required String sourcePath,
    required String targetPath,
    String? password,
  });

  Future<bool> installApk({
    required String apkPath,
    String? password,
  });

  /// 转发目标设备端口到本地
  Future<bool> forwardTcpToService({required int localPort, required String remoteService});
}

abstract class AdbDevice with AdbDeviceAbility {
  String serial;
  String stat;

  /// unique id
  String uid = '';

  /// password
  String password = '';

  String productModel = '';
  AdbDevice(this.serial, this.stat);

  @override
  bool operator ==(Object other) {
    if (other is! AdbDevice) {
      return false;
    }
    final AdbDevice adbDevice = other;
    return serial == adbDevice.serial;
  }

  @override
  int get hashCode => serial.hashCode;
}
