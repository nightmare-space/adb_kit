import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:adb_util/src/adb_command.dart';
import 'package:adb_util/src/adb_foundation.dart';
import 'package:android_api_server_client/src/client/aas_client.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:global_repository/global_repository_dart.dart';
import 'package:signale/signale.dart';

class StarterIsolateArgs {
  final String deviceID;
  final Map<String, dynamic> envir;
  final int rangeStart;
  final String? password;
  StarterIsolateArgs(
    this.deviceID,
    this.envir,
    this.rangeStart,
    this.password,
  );
}

String _tag = 'AAS Starter';

Future<String> getFlutterAssetsMD5(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    throw Exception('File not found: $path');
  }

  final bytes = await file.readAsBytes();
  final digest = md5.convert(bytes);
  return digest.toString();
}

/// 顶级函数，为了在 isolate 中调用
/// Process.start 在 UI 线程影响性能
/// TODO password
Future<int> startServerWithIsolate(StarterIsolateArgs args) async {
  RuntimeEnvir.initEnvirFromMap(args.envir);
  String aasDexPath = '${RuntimeEnvir.binPath}/app_server';
  String serverPath = '/data/local/tmp';
  String className = 'com.nightmare.aas_integrated.AASIntegrate';
  Stopwatch stopwatch = Stopwatch()..start();
  String suffix = await getFlutterAssetsMD5(aasDexPath);
  // await initSetting();
  Log.i('init setting time : ${stopwatch.elapsed}');
  stopwatch.reset();
  final Completer<int> completer = Completer();
  final String targetPath = '$serverPath/app_server$suffix';
  Log.i('targetPath -> $targetPath');
  try {
    await pushFile(
      serial: args.deviceID,
      sourcePath: aasDexPath,
      targetPath: targetPath,
      password: args.password,
    );
  } catch (e) {
    rethrow;
  }
  Log.i('push file time : ${stopwatch.elapsed}');
  stopwatch.reset();
  StringBuffer dexArg = StringBuffer();
  dexArg.write('-s ${args.deviceID} ');
  dexArg.write('shell ');
  dexArg.write('CLASSPATH=$targetPath ');
  dexArg.write('app_process ');
  dexArg.write('$serverPath ');
  dexArg.write('$className ');
  dexArg.write('default');
  final List<String> processArg = dexArg.toString().split(' ');
  // !注意这个要和applib中的一样
  const String startTag = 'success start port -> ';
  String execuable = 'adb';
  Process process = await Process.start(
    execuable,
    processArg,
    includeParentEnvironment: true,
    environment: adbEnvir(),
    runInShell: Platform.isWindows ? true : false,
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
          final int? bindPort = await forwardPort(
            serial: args.deviceID,
            rangeStart: args.rangeStart,
            rangeEnd: args.rangeStart + 10,
            targetArg: 'tcp:$dexPort',
          );
          completer.complete(bindPort);
        }
      }
    }
  });
  process.stderr.transform(utf8.decoder).listen((event) {
    Log.e('error : $event', tag: _tag);
    if (event.contains('please input verify password')) {
      // Log.e('please input verify password');
      process.stdin.writeln(args.password);
    }
  });
  process.exitCode.then((int code) {
    Log.e('exit code : $code');
  });
  return completer.future;
}

class AndroidAPIServerStarter {
  AndroidAPIServerStarter._();
  static Map<String, AASClient> serverStartList = {};
  static int rangeStart = 14040;

  static Future<AASClient> startServer(
    String serial, {
    String? password,
  }) async {
    if (serverStartList.containsKey(serial)) {
      return serverStartList[serial]!;
    }
    final int? port = await compute(
      startServerWithIsolate,
      StarterIsolateArgs(
        serial,
        RuntimeEnvir.environment,
        rangeStart,
        password,
      ),
    );
    rangeStart += 10;
    AASClient channel = AASClient(port: port);
    return serverStartList[serial] = channel;
  }
}
