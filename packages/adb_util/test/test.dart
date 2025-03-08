import 'dart:io';
import 'dart:math';

import '../lib/adb_util.dart';
import 'package:global_repository/global_repository_dart.dart' hide exec;
import 'package:test/test.dart';
import 'package:signale/signale.dart';

void main() {
  RuntimeEnvir.initEnvirWithPackageName('adb_kit_util', appSupportDirectory: './');
  int testCount = 1000;
  String testCMD = 'lib/packages/adb_util/test/test.sh';
  // adb = testCMD;
  String serial = '192.168.31.109:5555';
  serial = '240e:476:5f06:7c:52c3:a2ff:fe15:8f43';
  String password = 'adb369875';

  if (Platform.isWindows) {
    adb = r'res\windows\bin\adb.exe';
  }

  // TODO: Push File 要单独测，这个在安卓上从 stderr 中吐出来
  const SystemEncoding();
  group('test connect:', () {
    test(
      'connect no exist device',
      () async {
        try {
          await ADB.connectDevices('127.0.0.1:4444');
        } catch (e) {
          // `failed to connect to '127.0.0.1:4444': Connection refused`s
          expect(e, isA<ConnectRefused>());
        }
      },
    );
    test(
      'disconnect device',
      () async {
        try {
          String result = await ADB.disconnectDevice(serial);
          // common is `disconnected 192.168.31.109:5555`
          expect(result, contains(RegExp('disconnected')));
        } catch (e) {
          // common is `error: no such device '192.168.31.109:5555'`
          expect(e.toString(), contains('no such device'));
        }
      },
    );
    test(
      'connect device',
      () async {
        String? error;
        try {
          await ADB.connectDevices(serial);
        } catch (e) {
          error = e.toString();
        }
        expect(error, null);
      },
    );
    test(
      'connect already connected device',
      () async {
        try {
          await ADB.connectDevices(serial);
        } catch (e) {
          expect(e, isA<AlreadyConnected>());
        }
      },
    );
  });
  group(
    'test exception:',
    () {
      test("unknown command", () async {
        // devics for test exception
        try {
          await exec('$adb devics');
        } catch (e) {
          expect(e, contains('unknown command devics'));
        }
        try {
          await exec('$adb devics', useProcessRun: true);
        } catch (e) {
          expect(e, contains('unknown command devics'));
        }
      });
      test('unknown shell', () {});
    },
  );
  test('test exception', () async {
    try {
      await exec('$adb -s $serial shell xxx');
    } catch (e) {
      // /system/bin/sh: xxx: inaccessible or not found
      expect(e, contains('inaccessible or not found'));
    }
    try {
      await exec('$adb -s $serial shell xxx', useProcessRun: true);
    } catch (e) {
      // /system/bin/sh: xxx: inaccessible or not found
      expect(e, contains('inaccessible or not found'));
    }
  });
  // test('test extract address and port', () {
  //   String ipv6Address = '[240e:39c:3f:7300:278f:fd9a:c63f:cd1c]';
  //   String ipv6Port = '5557';
  //   String ipv4Address = '192.168.31.111';
  //   String ipv4Port = '5555';
  //   String loopIpv4Address = '127.0.0.1';
  //   String loopIpv4Port = '5556';

  //   ADBDevice ipv6 = ADBDevice('$ipv6Address:$ipv6Port', 'device');
  //   ADBDevice ipv4 = ADBDevice('$ipv4Address:$ipv4Port', 'device');
  //   ADBDevice loopIpv4 = ADBDevice('$loopIpv4Address:$loopIpv4Port', 'device');

  //   expect(ipv4.extractIp(), ipv4Address);
  //   expect(ipv4.extractPort(), ipv4Port);
  //   expect(loopIpv4.extractIp(), loopIpv4Address);
  //   expect(loopIpv4.extractPort(), loopIpv4Port);
  //   expect(ipv6.extractIp(), ipv6Address);
  //   expect(ipv6.extractPort(), ipv6Port);
  // });
  // group(
  //   'test adb password:',
  //   () {
  //     test(
  //       'wrong password test',
  //       () async {
  //         adb = testCMD;
  //         String? error;
  //         try {
  //           await pushFile(
  //             serial: serial,
  //             sourcePath: testCMD,
  //             targetPath: '/sdcard/test.sh',
  //           );
  //         } catch (e) {
  //           error = e.toString();
  //         }
  //         adb = 'adb';
  //         expect(error, 'password is null');
  //       },
  //     );
  //     test(
  //       'correct password test',
  //       () async {
  //         adb = testCMD;
  //         String stdout = await pushFile(
  //           serial: serial,
  //           sourcePath: testCMD,
  //           targetPath: '/sdcard/test.sh',
  //           password: password,
  //         );
  //         adb = 'adb';
  //         expect(stdout, contains('1 file pushed'));
  //       },
  //     );
  //   },
  // );
  // test('get device product', () async {
  //   Stopwatch stopwatch = Stopwatch()..start();
  //   String? product = await getDeviceProductModel(serial, password: password);
  //   Duration first = stopwatch.elapsed;
  //   // double get
  //   stopwatch.reset();
  //   product = await getDeviceProductModel(serial);
  //   Duration second = stopwatch.elapsed;
  //   Log.i('product : $product, time : $first, $second');
  // });
  // test('get adb kit nid', () async {
  //   // TODO 需要remove一下再测试
  //   try {
  //     await exec('$adb -s $serial shell rm /data/local/tmp/nid', useProcessRun: true);
  //   } catch (e) {}
  //   Stopwatch stopwatch = Stopwatch()..start();
  //   String? nid = await getDeviceID(serial, password: password);
  //   Duration first = stopwatch.elapsed;
  //   // double get
  //   stopwatch.reset();
  //   nid = await getDeviceID(serial);
  //   Duration second = stopwatch.elapsed;
  //   Log.i('nid : $nid, time : $first, $second');
  // });
  // test('forward port', () async {
  //   int start = 20000;
  //   int? port = await forwardPort(
  //     serial: serial,
  //     rangeStart: start,
  //     rangeEnd: start + 10,
  //   );
  //   Log.i('port : $port');
  //   expect(port, start);
  // });
  // test('write custom adbkit key', () {});

  // // 把这个测试放在安卓上跑
  // test('test exec cmd with start', () async {
  //   await testExecSpeed(testCount, false);
  // });
  // test('test exec cmd with run', () async {
  //   await testExecSpeed(testCount, true);
  // });
}

Future<void> testExecSpeed(int count, bool useProcessRun) async {
  int sumTime = 0;
  for (int i = 0; i < count; i++) {
    final Stopwatch stopwatch = Stopwatch()..start();
    // ignore: unused_local_variable
    String result = await exec('$adb devices', useProcessRun: useProcessRun);
    sumTime += stopwatch.elapsedMilliseconds;
  }
  Log.i('平均耗时:${sumTime / count}');
}
