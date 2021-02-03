import 'dart:io';

import 'package:global_repository/global_repository.dart';

class ScrcpyUtil {
  static Future<void> showDeviceScreen(String ip) async {
    await Process.run(
      'scrcpy',
      [
        '-s',
        ip,
      ],
      runInShell: true,
      includeParentEnvironment: true,
      environment: PlatformUtil.environment(),
    );
  }
}
