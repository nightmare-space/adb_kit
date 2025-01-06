import '../adb_util.dart';

Future<String> startServer() async {
  return await exec('$adb start-server', useProcessRun: true);
}

Future<String> pushFile({
  required String serial,
  required String sourcePath,
  required String targetPath,
  String? password,
}) async {
  try {
    // -s 192.168.31.110:5555 push /Users/nightmare/Downloads/shizuku-v13.5.4.r1049.0e53409-release (4).apk /storage/emulated/0/shizuku-v13.5.4.r1049.0e53409-release (4).apk
    // TODO 上面这个名称挂了
    String data = await execWL(
      [adb, '-s', serial, 'push', sourcePath, targetPath],
      password: password,
    );
    return data;
  } catch (e) {
    rethrow;
  }
}

Future<String> installApk({
  required String serial,
  required String path,
  String? password,
}) async {
  try {
    String data = await execWL(
      [adb, '-s', serial, 'install', '-t', path],
      password: password,
    );
    return data;
  } catch (e) {
    rethrow;
  }
}

/// rm file
Future<String> rm({
  required String serial,
  required String path,
  String? password,
}) async {
  return runShell(
    serial: serial,
    command: 'rm $path',
    password: password,
  );
}

/// pm install
Future<String> pmInstall({
  required String serial,
  required String path,
  String? password,
}) async {
  return runShell(
    serial: serial,
    command: 'pm install -r $path',
    password: password,
  );
}

Future<String> runShell({
  required String serial,
  required String command,
  String? password,
}) async {
  try {
    String data = await execWL(
      [adb, '-s', serial, 'shell', command],
      password: password,
    );
    return data;
  } catch (e) {
    rethrow;
  }
}

Future<String> wmSize({
  required String serial,
  String? password,
}) async {
  return runShell(serial: serial, command: 'wm size', password: password);
}

Future<bool> getSystemBool({
  required String serial,
  required String key,
  String? password,
}) async {
  String result = await getSystem(serial: serial, key: key, password: password);
  return result == '1';
}

Future<String> getSystem({
  required String serial,
  required String key,
  String? password,
}) async {
  return runShell(serial: serial, command: 'settings get system $key', password: password);
}

Future<String> setSystem({
  required String serial,
  required String key,
  required String value,
  String? password,
}) async {
  return runShell(serial: serial, command: 'settings put system $key $value', password: password);
}

Future<String> getTcpPort({
  required String serial,
  String? password,
}) {
  return getProp(serial: serial, key: 'service.adb.tcp.port', password: password);
}

Future<String> enableTcp5555({
  required String serial,
  String? password,
}) {
  return exec('$adb -s $serial tcpip 5555', useProcessRun: true);
}

Future<String> getProp({
  required String serial,
  required String key,
  String? password,
}) {
  return runShell(serial: serial, command: 'getprop $key', password: password);
}

Future<int?> forwardPort({
  required String serial,
  int rangeStart = 27183,
  int rangeEnd = 27199,
  String targetArg = 'localabstract:scrcpy',
}) async {
  while (rangeStart != rangeEnd) {
    try {
      String result = await exec('$adb -s $serial forward tcp:$rangeStart $targetArg', useProcessRun: true);
      // Log.d('port $rangeStart bind success result: $result');
      return rangeStart;
    } catch (e) {
      // Log.w('port $rangeStart bind failed, try next');
      rangeStart++;
    }
  }
  return null;
}
