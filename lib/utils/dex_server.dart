import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:adb_kit/material_entrypoint.dart';
import 'package:adb_kit/config/config.dart';
import 'package:adb_kit/config/settings.dart';
import 'package:adbutil/adbutil.dart';
import 'package:app_manager/app_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:settings/settings.dart';

class IsolateArgs {
  final String deviceID;
  final Map<String, dynamic> envir;
  final int rangeStart;
  IsolateArgs(this.deviceID, this.envir, this.rangeStart);
}

/// 顶级函数，为了在 isolate 中调用
/// Process.start 在 UI 线程影响性能
Future<int> startServerWithIsolate(IsolateArgs args) async {
  RuntimeEnvir.initEnvirFromMap(args.envir);
  Stopwatch stopwatch = Stopwatch()..start();
  String suffix = Config.versionCode;
  await initSetting();
  Log.i('init setting time : ${stopwatch.elapsed}');
  stopwatch.reset();
  final Completer<int> completer = Completer();
  String serverPath = Settings.serverPath.setting.get();
  if (serverPath.isEmpty) {
    serverPath = Config.adbLocalPath;
  }
  final String targetPath = '$serverPath/app_server$suffix';
  Log.i('targetPath -> $targetPath');
  // 上传server文件
  await AdbUtil.pushFile(args.deviceID, '${RuntimeEnvir.binPath}/app_server', targetPath);
  Log.i('push file time : ${stopwatch.elapsed}');
  stopwatch.reset();
  StringBuffer dexArg = StringBuffer();
  dexArg.write('-s ${args.deviceID} ');
  dexArg.write('shell ');
  dexArg.write('CLASSPATH=$targetPath ');
  dexArg.write('app_process ');
  dexArg.write('$serverPath ');
  dexArg.write('com.nightmare.applib.AppServer ');
  dexArg.write('default');
  final List<String> processArg = dexArg.toString().split(' ');
  // !注意这个要和applib中的一样
  const String startTag = 'success start port -> ';
  String execuable = adb;
  Process process = await Process.start(
    execuable,
    processArg,
    includeParentEnvironment: true,
    environment: adbEnvir(),
    runInShell: GetPlatform.isWindows ? true : false,
  );
  StringBuffer printBuff = StringBuffer();
  process.stdout.transform(utf8.decoder).listen((event) async {
    if (event.isEmpty) {
      return;
    }
    printBuff.write(event);
    if ('$printBuff'.trim().isNotEmpty && '$printBuff'.contains('\n')) {
      // 解决有时候打印一个点就占用一行的问题
      Log.w('$printBuff'.trim(), tag: 'dex server');
      printBuff.clear();
    }
    // `success start port -> 15000.`
    if (event.contains(startTag)) {
      for (final String line in event.split('\n')) {
        // 说明服务启动了
        if (line.contains(startTag)) {
          String portStr = line.replaceAll(RegExp('.*> |\\..*'), '');
          final int? dexPort = int.tryParse(portStr);
          final int? forwardPort = await AdbUtil.getForwardPort(
            args.deviceID,
            rangeStart: args.rangeStart,
            rangeEnd: args.rangeStart + 10,
            targetArg: 'tcp:$dexPort',
          );
          completer.complete(forwardPort);
        }
      }
    }
  });
  process.stderr.transform(utf8.decoder).listen((event) {
    Log.e('error : $event');
  });
  process.exitCode.then((int code) {
    Log.e('exit code : $code');
  });
  return completer.future;
}

class DexServer {
  DexServer._();
  static Map<String, AppChannel> serverStartList = {};
  static int rangeStart = 14040;

  static Future<AppChannel> startServer(String devicesId) async {
    if (serverStartList.containsKey(devicesId)) {
      return serverStartList[devicesId]!;
    }
    final int? port = await compute(
      startServerWithIsolate,
      IsolateArgs(devicesId, RuntimeEnvir.environment, rangeStart),
    );
    rangeStart += 10;
    AppChannel channel = AppChannel(port: port);
    return serverStartList[devicesId] = channel;
  }
}
