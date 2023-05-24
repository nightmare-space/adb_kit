import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:adb_kit/material_entrypoint.dart';
import 'package:adb_kit/config/config.dart';
import 'package:adb_kit/config/settings.dart';
import 'package:adbutil/adbutil.dart';
import 'package:app_manager/app_manager.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:settings/settings.dart';

///
/// 无界投屏也会直接依赖这个
///

class DexServer {
  DexServer._();
  static Map<String, AppChannel> serverStartList = {};
  static int rangeStart = 14040;
  // TODO(nightmare):这个最终应该改成isolate，
  static Future<AppChannel?> startServer(String devicesId) async {
    Stopwatch stopwatch = Stopwatch()..start();
    String suffix = Config.versionCode;
    await initSetting();
    Log.i('init setting time : ${stopwatch.elapsed}');
    stopwatch.reset();
    if (serverStartList.keys.contains(devicesId)) {
      return serverStartList[devicesId];
    }
    final Completer<AppChannel> completer = Completer();
    String serverPath = Settings.serverPath.setting.get();
    if (serverPath.isEmpty) {
      serverPath = Config.adbLocalPath;
    }
    final String targetPath = '$serverPath/app_server$suffix';
    Log.i('targetPath -> $targetPath');
    // 上传server文件
    await AdbUtil.pushFile(
      devicesId,
      '${RuntimeEnvir.binPath}/app_server',
      targetPath,
    );
    Log.i('push file time : ${stopwatch.elapsed}');
    stopwatch.reset();
    final List<String> processArg = '-s $devicesId shell CLASSPATH=$targetPath app_process $serverPath com.nightmare.applib.AppServer'.split(' ');

    /// 注意这个要和applib中的一样哦
    const String startTag = 'success start port : ';
    String execuable = adb;
    // TODO 测试是否影响其他平台
    // if (Platform.isWindows) {
    //   execuable = RuntimeEnvir.binPath + Platform.pathSeparator + execuable;
    // }
    Process.start(
      execuable,
      processArg,
      includeParentEnvironment: true,
      environment: adbEnvir() as Map<String, String>?,
      runInShell: GetPlatform.isWindows ? true : false,
      // mode: ProcessStartMode.inheritStdio,
    ).then((value) {
      StringBuffer printBuff = StringBuffer();
      value.stdout.transform(utf8.decoder).listen((event) async {
        if (event.isEmpty) {
          return;
        }
        printBuff.write(event);
        if (printBuff.toString().trim().isNotEmpty && printBuff.toString().contains('\n')) {
          // 解决有时候打印一个点就占用一行的问题
          Log.w(printBuff.toString().trim(), tag: 'dex server');
          printBuff.clear();
        }
        if (event.contains(startTag)) {
          Log.w('serverStartList -> $serverStartList');
          for (final String line in event.split('\n')) {
            if (line.contains(startTag)) {
              Log.e('started time:${stopwatch.elapsed}');
              // 这个端口是对方设备成功绑定的端口
              final int? remotePort = int.tryParse(line.replaceAll(RegExp('.*>|<.*'), ''));
              Log.d('Dex Server Start Port -> $remotePort');
              // 这个端口是本机成功绑定的端口
              final int? localPort = await AdbUtil.getForwardPort(
                devicesId,
                rangeStart: rangeStart,
                rangeEnd: rangeStart + 10,
                targetArg: 'tcp:$remotePort',
              );
              rangeStart += 10;
              Log.d('ADB Forward LocalPort -> $localPort');
              // 这样才能保证列表正常
              final RemoteAppChannel channel = RemoteAppChannel(port: localPort);
              Log.i('channel -> ${channel.port}');
              serverStartList[devicesId] = channel;
              Get.put<AppChannel>(channel);
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
