import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/config/settings.dart';
import 'package:adb_tool/main.dart';
import 'package:adbutil/adbutil.dart';
import 'package:app_manager/app_manager.dart';
import 'package:global_repository/global_repository.dart';
import 'package:settings/settings.dart';

///
/// 无界投屏也会直接依赖这个
///
   
class DexServer {
  DexServer._();
  static List<String> serverStartList = [];
  static Completer lock;
  static Future<void> startServer(String devicesId) async {
    await initSetting();
    if (lock != null && !lock.isCompleted) {
      Log.d('等待startServer lock');
      await lock.future;
    }
    if (serverStartList.contains(devicesId)) {
      return;
    }
    lock = Completer();
    // 当锁用
    final Completer<void> completer = Completer();
    String serverPath = Settings.serverPath.get;
    if (serverPath.isEmpty) {
      serverPath = Config.adbLocalPath;
    }
    final String targetPath = '$serverPath/app_server';
    // 上传server文件
    await AdbUtil.pushFile(
      devicesId,
      '${RuntimeEnvir.binPath}/app_server',
      targetPath,
    );
    final List<String> processArg =
        '-s $devicesId shell CLASSPATH=$targetPath app_process $serverPath com.nightmare.applib.AppChannel'
            .split(' ');

    const String startTag = 'success start:';
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    Process.start(
      'adb',
      processArg,
      includeParentEnvironment: true,
      environment: RuntimeEnvir.envir(),
      // mode: ProcessStartMode.inheritStdio,
    ).then((value) {
      value.stdout.transform(utf8.decoder).listen((event) async {
        Log.w(event, tag: 'dex server');
        if (event.contains(startTag)) {
          serverStartList.add(devicesId);
          Log.w('serverStartList -> $serverStartList');
          for (final String line in event.split('\n')) {
            if (line.contains(startTag)) {
              Log.e('time:${stopwatch.elapsed}');
              // 这个端口是对方设备成功绑定的端口
              final int remotePort =
                  int.tryParse(line.replaceAll(startTag, ''));
              // 这个端口是本机成功绑定的端口
              final int localPort = await AdbUtil.getForwardPort(
                devicesId,
                rangeStart: 6000,
                rangeEnd: 6040,
                targetArg: 'tcp:$remotePort',
              );
              Log.d('localPort -> $localPort');
              // 这样才能保证列表正常
              final RemoteAppChannel channel = RemoteAppChannel();
              channel.port = localPort;
              channel.serial = devicesId;
              AppManager.globalInstance.appChannel = channel;
              AppManager.globalInstance.process = YanProcess()
                ..exec('adb -s $devicesId shell');
              lock.complete();
              completer.complete();
            }
          }
        }
      });
      value.stderr.transform(utf8.decoder).listen((event) {
        Log.e('error : $event');
      });
    });
    return completer.future;
  }
}
