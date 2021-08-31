import 'dart:io';

import 'package:global_repository/global_repository.dart';
import 'package:termare_pty/termare_pty.dart';

class TerminalUtil {
  const TerminalUtil._();
  static PseudoTerminal getShellTerminal() {
    String executable = '';
    if (Platform.environment.containsKey('SHELL')) {
      executable = Platform.environment['SHELL'];
      // 取的只是执行的文件名
      executable = executable.replaceAll(RegExp('.*/'), '');
    } else {
      if (Platform.isMacOS) {
        executable = 'bash';
      } else if (Platform.isWindows) {
        executable = 'cmd';
      } else if (Platform.isAndroid) {
        executable = 'sh';
      }
    }
    Directory(RuntimeEnvir.homePath).createSync(recursive: true);
    Directory(RuntimeEnvir.tmpPath).createSync(recursive: true);
    final Map<String, String> environment = {
      'TERM': 'xterm-256color',
      'PATH': PlatformUtil.environment()['PATH'],
      'TMPDIR': RuntimeEnvir.tmpPath,
      'HOME': RuntimeEnvir.homePath,
    };
    return PseudoTerminal(
      executable: executable,
      workingDirectory: RuntimeEnvir.homePath,
      environment: environment,
      arguments: ['-l'],
    );
  }
}
