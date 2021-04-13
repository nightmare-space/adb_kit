import 'dart:io';

import 'package:global_repository/global_repository.dart';

class AdbUtil {
  static Future<void> connectDevices(String ipAndPort) async {
    String port = '5555';
    String ip = ipAndPort.split(':').first;
    if (ipAndPort.contains(':')) {
      port = ipAndPort.split(':').last;
    }
    // Todo
    final ProcessResult result = await Process.run(
      'adb',
      [
        'connect',
        ipAndPort,
      ],
      runInShell: true,
      includeParentEnvironment: true,
      environment: PlatformUtil.environment(),
    );
    final String stdout = result.stdout.toString();
    if (stdout.contains('refused')) {
      showToast('$ip 下的 $port 端口无法连接');
    } else if (stdout.contains('unable to connect')) {
      showToast('连接失败，对方设备可能未打开网络ADB调试');
    } else if (stdout.contains('already connected')) {
      showToast('该设备已连接');
    } else if (stdout.contains('connect')) {
      showToast('连接成功');
    }
    print('result.stdout -> ${result.stdout}');
    print('result.stderr -> ${result.stderr}');
  }

  static Future<void> disconnectDevices(String ip) async {
    final ProcessResult result = await Process.run(
      'adb',
      [
        'disconnect',
        ip + ':5555',
      ],
      runInShell: true,
      includeParentEnvironment: true,
      environment: PlatformUtil.environment(),
    );

    print('result.stdout -> ${result.stdout}');
    print('result.stderr -> ${result.stderr}');
  }
}
