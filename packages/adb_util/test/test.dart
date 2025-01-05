import 'package:adb_util/adb_util.dart';
import 'package:global_repository/global_repository_dart.dart' hide exec;
import 'package:test/test.dart';
import 'package:signale/signale.dart';

void main() {
  RuntimeEnvir.initEnvirWithPackageName('adb_kit_util', appSupportDirectory: './');
  int testCount = 1000;
  String testCMD = '/Users/nightmare/Desktop/nightmare-core/adb_kit/packages/adb_util/test/test.sh';
  // adb = testCMD;
  String serial = '192.168.31.111:5555';
  String password = 'adb369875';

  // test('test exception', () async {
  //   try {
  //     String result = await exec(testCMD, password: '123');
  //     print('result : $result');
  //   } catch (e) {
  //     print('error : $e');
  //   }
  // });
  // test('write custom adbkit key', () {});
  ADBDevice adbDevice = ADBDevice('192.168.31.111:5555', 'device');
  ADBDevice ipv6Device = ADBDevice('[240e:39c:3f:7300:278f:fd9a:c63f:cd1c]:5555', 'device');
  Log.i(adbDevice.extractIp());
  Log.i(ipv6Device.extractIp());
  group('push file', () {
    test('push file exception', () async {
      try {
        await pushFile(
          serial: serial,
          sourcePath: testCMD,
          targetPath: '/sdcard/test.sh',
        );
        throw 'error';
      } catch (e) {
        Log.i('test passed, error : $e');
      }
    });
    test('push file wrong password', () async {
      try {
        await pushFile(
          serial: serial,
          sourcePath: testCMD,
          targetPath: '/sdcard/test.sh',
          password: 'xxx',
        );
        throw 'error';
      } catch (e) {
        Log.i('test passed, error : $e');
      }
    });
    test('push file success', () async {
      try {
        await pushFile(
          serial: serial,
          sourcePath: testCMD,
          targetPath: '/sdcard/test.sh',
          password: password,
        );
      } catch (e) {
        Log.e('error : $e');
        rethrow;
      }
    });
  });
  test('forward port', () async {
    int start = 20000;
    int? port = await forwardPort(
      serial: serial,
      rangeStart: start,
      rangeEnd: start + 10,
    );
    Log.i('port : $port');
  });

  test('get device product', () async {
    Stopwatch stopwatch = Stopwatch()..start();
    String? product = await getDeviceProductModel(serial, password: password);
    Log.i('product : $product, time : ${stopwatch.elapsed}');
    // double get
    stopwatch.reset();
    product = await getDeviceProductModel(serial);
    Log.i('product : $product, time : ${stopwatch.elapsed}');
  });
  test('get adb kit nid', () async {
    Stopwatch stopwatch = Stopwatch()..start();
    String? nid = await getDeviceID(serial, password: password);
    Log.i('nid : $nid, time : ${stopwatch.elapsed}');
    // double get
    stopwatch.reset();
    nid = await getDeviceID(serial);
    Log.i('nid : $nid, time : ${stopwatch.elapsed}');
  });
  // 把这个测试放在安卓上跑
  test('test exec cmd with start', () async {
    await testExecSpeed(testCount, false);
  });
  test('test exec cmd with run', () async {
    await testExecSpeed(testCount, true);
  });
}

Future<void> testExecSpeed(int count, bool useProcessRun) async {
  int sumTime = 0;
  for (int i = 0; i < count; i++) {
    final Stopwatch stopwatch = Stopwatch()..start();
    // ignore: unused_local_variable
    String result = await exec('$adb devices', useProcessRun: useProcessRun);
    // print(result);
    // print('耗时:${stopwatch.elapsedMilliseconds}');
    sumTime += stopwatch.elapsedMilliseconds;
  }
  Log.i('平均耗时:${sumTime / count}');
}
