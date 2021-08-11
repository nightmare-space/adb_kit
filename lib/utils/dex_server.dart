import 'dart:async';
import 'package:adb_tool/global/instance/global.dart';
import 'package:global_repository/global_repository.dart';

class DexServer {
  static Future<void> startServer(String devicesId) async {
    final Completer<void> completer = Completer();
    final YanProcess process = YanProcess();
    Log.w('adb -s $devicesId forward tcp:4041 local:app_manager');
    Log.w(await process.exec('adb -s $devicesId forward tcp:6001 tcp:6000'));
    Log.w(await process.exec(
      'adb -s $devicesId push "${RuntimeEnvir.binPath}/app-release.apk" /data/local/tmp/base.apk',
    ));
    Global().pseudoTerminal.write(
        'adb -s $devicesId shell CLASSPATH=/data/local/tmp/base.apk app_process /data/local/tmp/ com.nightmare.appmanager.AppInfo\n');
    // process.processStdout.transform(utf8.decoder).listen((event) {
    //   Log.e('event -> $event');
    //   if(event.contains('wait')){
    //     completer.complete();
    //   }

    // });
    Global().pseudoTerminal.out.listen((event) {
      Log.e('event -> $event');
      if (event.contains('wait')) {
        completer.complete();
      }
    });
    Log.w(
        'adb -s $devicesId shell CLASSPATH=/data/local/tmp/base.apk app_process /data/local/tmp/ com.nightmare.appmanager.AppInfo');
    // process.exec(
    //     'adb -s $devicesId shell CLASSPATH=/data/local/tmp/base.apk app_process /data/local/tmp/ com.nightmare.appmanager.AppInfo &');
    return completer.future;
  }
}
