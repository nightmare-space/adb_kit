import 'dart:async';
import 'package:adbutil/adbutil.dart';
import 'package:global_repository/global_repository.dart';
import 'package:pseudo_terminal_utils/pseudo_terminal_utils.dart';
import 'package:termare_pty/termare_pty.dart';

class DexServer {
  DexServer._();
  static bool serverStart = false;
  static Future<void> startServer(String devicesId) async {
    if (serverStart) {
      return;
    }
    final Completer<void> completer = Completer();

    final YanProcess process = YanProcess();
    await process.exec('adb -s $devicesId forward tcp:6001 tcp:6000');
    await AdbUtil.pushFile(
      devicesId,
      '${RuntimeEnvir.binPath}/server.jar',
      '/data/local/tmp/base.apk',
    );
    final List<String> processArg =
        '-s $devicesId shell CLASSPATH=/data/local/tmp/base.apk app_process /data/local/tmp/ com.nightmare.appmanager.AppChannel'
            .split(' ');
    final PseudoTerminal pty = TerminalUtil.getShellTerminal(
      exec: 'adb',
      arguments: processArg,
    );
    pty.startPolling();
    pty.out.listen((event) {
      Log.e('event -> $event');
      if (event.contains('success start')) {
        serverStart = true;
        completer.complete();
      }
      pty.schedulingRead();
    });
    return completer.future;
  }
}
