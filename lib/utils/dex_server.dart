import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:adb_tool/material_entrypoint.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/config/settings.dart';
import 'package:adbutil/adbutil.dart';
import 'package:app_manager/app_manager.dart';
import 'package:app_manager/core/interface/app_channel.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:settings/settings.dart';

///
/// 无界投屏也会直接依赖这个
///

class DexServer {
  DexServer._();
  static Map<String, AppChannel> serverStartList = {};
  static int rangeStart = 6040;
  // TODO(nightmare):这个最终应该改成isolate，
  static Future<AppChannel> startServer(String devicesId) async {
    await initSetting();
    if (serverStartList.keys.contains(devicesId)) {
      return serverStartList[devicesId];
    }
    final Completer<AppChannel> completer = Completer();
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
    final List<String> processArg = '-s $devicesId shell CLASSPATH=$targetPath app_process $serverPath com.nightmare.applib.AppServer'.split(' ');

    /// 注意这个要和applib中的一样哦
    const String startTag = 'success start port : ';
    Stopwatch stopwatch = Stopwatch();
    stopwatch.start();
    String execuable = adb;
    // TODO 测试是否影响其他平台
    // if (Platform.isWindows) {
    //   execuable = RuntimeEnvir.binPath + Platform.pathSeparator + execuable;
    // }
    Process.start(
      execuable,
      processArg,
      includeParentEnvironment: true,
      environment: adbEnvir(),
      runInShell: GetPlatform.isWindows ? true : false,
      // mode: ProcessStartMode.inheritStdio,
    ).then((value) {
      value.stdout.transform(utf8.decoder).listen((event) async {
        Log.w(event.trim(), tag: 'dex server');
        if (event.contains(startTag)) {
          Log.w('serverStartList -> $serverStartList');
          for (final String line in event.split('\n')) {
            if (line.contains(startTag)) {
              Log.e('time:${stopwatch.elapsed}');
              // 这个端口是对方设备成功绑定的端口
              Log.d(line);
              Log.d(line.replaceAll(RegExp('.*>|<.*'), ''));
              final int remotePort = int.tryParse(line.replaceAll(RegExp('.*>|<.*'), ''));
              Log.d('remotePort -> $remotePort');
              // 这个端口是本机成功绑定的端口
              final int localPort = await AdbUtil.getForwardPort(
                devicesId,
                rangeStart: rangeStart,
                rangeEnd: rangeStart + 10,
                targetArg: 'tcp:$remotePort',
              );
              rangeStart += 10;
              Log.d('localPort -> $localPort');
              // 这样才能保证列表正常
              final RemoteAppChannel channel = RemoteAppChannel();
              channel.port = localPort;
              channel.serial = devicesId;
              serverStartList[devicesId] = channel;
              completer.complete(channel);
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
