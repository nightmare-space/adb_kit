import 'dart:io';

import 'package:global_repository/global_repository.dart';

class AdbUtil {
  static Future<void> connectDevices(String ip) async {
    final ProcessResult result = await Process.run(
      'adb',
      [
        'connect',
        ip + ':5555',
      ],
      runInShell: true,
      includeParentEnvironment: true,
      environment: PlatformUtil.environment(),
    );
    if (result.stdout.toString().contains('unable to connect')) {
      NiToast.showToast('连接失败，对方设备可能未打开网络ADB调试');
    }
    print('result.stdout -> ${result.stdout}');
    print('result.stderr -> ${result.stderr}');
  }
}
