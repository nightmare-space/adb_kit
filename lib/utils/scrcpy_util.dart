import 'dart:io';

import 'package:global_repository/global_repository.dart';

class ScrcpyUtil {
  ScrcpyUtil._();
  static Future<void> showDeviceScreen(String ip) async {
    final ProcessResult result = await Process.run(
      'scrcpy',
      [
        '-s',
        ip,
      ],
      runInShell: true,
      includeParentEnvironment: true,
      environment: RuntimeEnvir.envir(),
    );

    Log.v('result.stdout -> ${result.stdout}');
    Log.v('result.stderr -> ${result.stderr}');
  }
}
