import '../adb_util.dart';
import 'package:signale/signale.dart';

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
    String data = await execWL(
      [
        adb,
        '-s',
        serial,
        'push',
        sourcePath,
        targetPath,
      ],
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
      [
        adb,
        '-s',
        serial,
        'install',
        '-t',
        path,
      ],
      password: password,
    );
    return data;
  } catch (e) {
    rethrow;
  }
}

Future<String> runShell({
  required String serial,
  required String command,
  String? password,
}) async {
  try {
    String data = await execWL(
      [
        adb,
        '-s',
        serial,
        'shell',
        command,
      ],
      password: password,
    );
    return data;
  } catch (e) {
    rethrow;
  }
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

Future<String> getProp({
  required String serial,
  required String key,
  String? password,
}) {
  return runShell(serial: serial, command: 'getprop $key', password: password);
}

Future<String> getExternalStoragePath({
  required String serial,
  String? password,
}) async {
  try {
    String data = await execWL(
      [
        adb,
        '-s',
        serial,
        'shell',
        'echo',
        '\$EXTERNAL_STORAGE',
      ],
      password: password,
    );
    return data;
  } catch (e) {
    rethrow;
  }
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
      Log.d('port $rangeStart bind success result: $result');
      return rangeStart;
    } catch (e) {
      Log.w('port $rangeStart bind failed, try next');
      rangeStart++;
    }
  }
  return null;
}
