import 'dart:io';

import 'platform_util.dart';

Future<String> exec(String cmd) async {
  final ProcessResult result = await Process.run(
    'sh',
    [
      '-c',
      '''
                        $cmd
                        '''
    ],
    environment: PlatformUtil.environment(),
  );
  String value = result.stdout.toString().trim();
  value += result.stderr.toString().trim();
  return value;
}
