import 'dart:async';
import 'dart:convert';
import 'package:adb_util/adb_util_flutter.dart';
import 'package:adb_util/src/utils/utils.dart';
import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:global_repository/global_repository_dart.dart' hide exec;

extension AdbDeviceExtension on AdbDevice {
  bool get isConnect => stat == 'device';

  /// 获取 ADB TCP 端口
  Future<String> getTcpPort({
    String? password,
  }) {
    return getProp(key: 'service.adb.tcp.port', password: password);
  }

  /// 获取设备属性
  Future<String> getProp({
    required String key,
    String? password,
  }) {
    return runShell('getprop $key', password: password);
  }

  /// 设置系统属性值
  Future<String> setSystemValue({
    required String key,
    required String value,
    String? password,
  }) async {
    return runShell('settings put system $key $value', password: password);
  }

  /// 获取系统属性值
  Future<T> getSystemValue<T>({
    required String key,
    String? password,
  }) async {
    if (T is String) {
      return await runShell('settings get system $key', password: password) as T;
    }
    if (T is bool) {
      String result = await runShell('settings get system $key', password: password);
      return (result.trim() == '1') as T;
    }
    throw UnsupportedError('Unsupported type');
  }

  /// 删除文件
  Future<void> deleteFile({
    required String path,
    String? password,
  }) async {
    await runShell('rm $path', password: password);
  }

  /// 获取设备型号
  Future<String> getDeviceProductModel({
    String? password,
  }) async {
    if (modelCache.containsKey(serial)) {
      // Log.i('get model from cache');
      return modelCache[serial]!;
    }
    String? model;
    try {
      // Some device like xiaomi can't get model name by `ro.product.marketname`
      model = await runShell('getprop ro.product.marketname', password: password);
      if (model.trim().isEmpty) {
        model = await runShell('getprop ro.product.model', password: password);
      }
      modelCache[serial] = model;
    } catch (e) {
      rethrow;
    }
    return model;
  }

  /// 因为有可能有多个相同的设备，不同用 adb 命令获取唯一 id
  Future<String?> getDeviceUniqueID({
    String? password,
  }) async {
    if (deviceIDCache.containsKey(serial)) {
      return deviceIDCache[serial];
    }
    String cmd = 'cat /data/local/tmp/nid';
    String? id;
    try {
      id = await runShell(cmd, password: password);
    } catch (e) {
      Log.i('cat nid failed : $e try write a new one and get again');
      try {
        await writeKey(serial, password);
        id = await runShell(cmd, password: password);
      } catch (e, stackTrace) {
        Log.e("important error -> $e $stackTrace");
      }
    }
    deviceIDCache[serial] = id ?? 'unknown';
    return deviceIDCache[serial];
  }

  String removePort(String address) {
    // 检查是否包含端口
    if (address.contains(':')) {
      // 如果是 IPv6 地址，端口前会有一个单独的冒号
      if (address.contains('[') && address.contains(']')) {
        return '${address.split(']:')[0]}]';
      } else {
        // IPv4 地址或没有方括号的IPv6地址
        return address.split(':')[0];
      }
    }
    // 如果不包含端口，直接返回原地址
    return address;
  }

  /// for example:
  /// [240e:39c:3f:7300:278f:fd9a:c63f:cd1c]:5555 will get [240e:39c:3f:7300:278f:fd9a:c63f:cd1c]
  /// note: ipv6 address will be wrapped in square brackets
  /// 192.168.31.111:5555 will get 192.168.31.111
  String extractIp() {
    return removePort(serial);
  }

  String extractPort() {
    return serial.split(':').last;
  }

  /// 判断 serial 是否是 ipv4/ipv6
  /// check serial is ipv4/ipv6
  /// TODO adb-8c922a7e-cFqP8C._adb-tls-connect._tcp 也是一个网络设备
  bool get isNetworkDevice {
    return serial.contains(':');
  }

  static int rangeStart = 14040;
  static Map<String, AASClient> aasCache = {};
  Future<AASClient> startServer({
    String? password,
  }) async {
    Stopwatch stopwatch = Stopwatch()..start();
    String tag = 'aas starter';
    // - push file -
    String aasDexPath = '${RuntimeEnvir.binPath}/app_server';
    String serverPath = '/data/local/tmp';
    String suffix = await getFileMD5(aasDexPath);
    final String targetPath = '$serverPath/app_server$suffix';
    final serialCopy = serial;
    //
    // if (_debug && Platform.isMacOS) {
    //   aasDexPath = './app_server';
    // }
    Log.i('targetPath -> $targetPath');
    try {
      await pushFile(
        sourcePath: aasDexPath,
        targetPath: targetPath,
        password: password,
      );
    } catch (e) {
      Log.e('push file error : $e', 'pushAasDex');
      // rethrow;
    }
    Log.i('push file time : ${stopwatch.elapsed}', tag);
    // - push file -
    int aasPort = 0;
    if (this is AdbDeviceBinary) {
      // aasPort = await Isolate.run(() async {
      //   // TODO 应该在这儿在构造一个 AdbDeviceBinary，然后调用它的 startAasWithAdbBinary
      //   Stopwatch stopwatch = Stopwatch()..start();
      //   // RuntimeEnvir.initEnvirFromMap(args.envir);
      //   String className = 'com.nightmare.aas_integrated.AASIntegrate';
      //   // - generate dex arguments -
      //   StringBuffer dexArg = StringBuffer();
      //   dexArg.write('-s $serialCopy ');
      //   dexArg.write('shell ');
      //   dexArg.write('CLASSPATH=$targetPath ');
      //   dexArg.write('app_process ');
      //   dexArg.write('$serverPath ');
      //   dexArg.write('$className ');
      //   dexArg.write('default');
      //   final List<String> processArg = dexArg.toString().split(' ');
      //   Log.i('arg -> ${processArg.join(' ')}', tag);
      //   // - generate dex arguments -
      //   int aasPort = await startAasWithAdbBinary(processArg);
      //   Log.i('start aas time : ${stopwatch.elapsed}', tag);
      //   return aasPort;
      // });
    } else {
      final Completer<int> completer = Completer();
      ShellSession session = await openShellSession(
        password: password,
      );
      Stopwatch stopwatch = Stopwatch()..start();
      String className = 'com.nightmare.aas_integrated.AASIntegrate';
      // - generate dex arguments -
      StringBuffer dexArg = StringBuffer();
      dexArg.write('CLASSPATH=$targetPath ');
      dexArg.write('app_process ');
      dexArg.write('$serverPath ');
      dexArg.write('$className ');
      dexArg.write('default');
      final String command = dexArg.toString();
      Log.i('command -> $command', tag);
      // - generate dex arguments -
      String startTag = 'success start port -> ';
      session.output.listen((event) async {
        String output = utf8.decode(event);
        Log.i(output.replaceAll('\n', '').trim(), tag);
        if (output.contains(startTag)) {
          for (final String line in output.split('\n')) {
            // 说明服务启动了
            if (line.contains(startTag)) {
              String portStr = line.replaceAll(RegExp('.*> |\\..*'), '');
              final int? dexPort = int.tryParse(portStr);
              int rangeEnd = rangeStart + 10;
              int successPort = rangeStart;
              while (successPort != rangeEnd) {
                bool success = await forwardTcpToService(localPort: rangeStart, remoteService: 'tcp:$dexPort');
                if (success) {
                  break;
                }
                successPort++;
              }
              rangeStart = rangeEnd;
              completer.complete(successPort);
            }
          }
        }
      });
      session.write(utf8.encode('$command\n'));
      aasPort = await completer.future;
    }
    AASClient aas = AASClient(port: aasPort);
    return aas;
  }

  // Future<int> startAasWithAdbBinary(List<String> args) async {
  //   final Completer<int> completer = Completer();
  //   // !注意这个要和applib中的一样
  //   String startTag = 'success start port -> ';
  //   String execuable = 'adb';
  //   Process process = await Process.start(
  //     execuable,
  //     args,
  //     includeParentEnvironment: true,
  //     environment: adbEnvir(),
  //     runInShell: Platform.isWindows ? true : false,
  //   );
  //   StringBuffer printBuff = StringBuffer();
  //   process.stdout.transform(utf8.decoder).listen((event) async {
  //     if (event.isEmpty) {
  //       return;
  //     }
  //     printBuff.write(event);
  //     if ('$printBuff'.trim().isNotEmpty && '$printBuff'.contains('\n')) {
  //       // 解决有时候打印一个点就占用一行的问题
  //       Log.w('$printBuff'.trim(), 'dex server');
  //       printBuff.clear();
  //     }
  //     // `success start port -> 15000.`
  //     if (event.contains(startTag)) {
  //       for (final String line in event.split('\n')) {
  //         // 说明服务启动了
  //         if (line.contains(startTag)) {
  //           String portStr = line.replaceAll(RegExp('.*> |\\..*'), '');
  //           final int? dexPort = int.tryParse(portStr);
  //           final int? bindPort = await forwardPort(
  //             serial: serial,
  //             rangeStart: rangeStart,
  //             rangeEnd: rangeStart + 10,
  //             targetArg: 'tcp:$dexPort',
  //           );
  //           completer.complete(bindPort);
  //         }
  //       }
  //     }
  //   });
  //   process.stderr.transform(utf8.decoder).listen((event) {
  //     Log.e('error : $event', 'aas starter');
  //     if (event.contains('please input verify password')) {
  //       // Log.e('please input verify password');
  //       process.stdin.writeln(password);
  //     }
  //   });
  //   process.exitCode.then((int code) {
  //     Log.e('exit code : $code');
  //   });
  //   return completer.future;
  // }
}

Future<void> writeKey(String serial, String? password) async {
  String nidPath = '/data/local/tmp/nid';
  String id = shortHash(() {}).toString();
  await execWL(
    [adb, '-s', serial, 'shell', 'echo $id > $nidPath'],
    password: password,
  );
  // TODO 下面代码在 Linux/Mac 正常，在 Windows 崩了
  // String test = await exec('$adb -s $serial shell echo $id', password: password);
  // Log.e('test -> $test');
}
