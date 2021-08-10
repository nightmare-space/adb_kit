import 'dart:io';

import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

Future<String> execCmd(String cmd) async {
  final List<String> args = cmd.split(' ');
  String out;
  if (kIsWeb) {
    out = '''
List of devices attached
192.168.213.32:5555	device
emulator-5554	device
''';
    out = out.trim();
  } else if (Platform.isWindows) {
    String stdout;
    final ProcessResult result = await Process.run(
      args[0],
      args.sublist(1),
      environment: PlatformUtil.environment(),
      runInShell: true,
    );
    stdout = result.stdout.toString();
    out = stdout.trim();
  } else {
    // NiProcess 是一个自定义的 Process，因为可能存在使用一个带 root
    // 权限的流
    Log.e('exec');
    Log.w(await Global().process.exec('env'));
    out = (await Global().process.exec(cmd)).trim();
    Log.w(out);
    Log.e('exec down');
  }
  return out;
}

class DevicesEntity {
  DevicesEntity(this.serial, this.stat);
  // 有可能是ip或者设备序列号
  final String serial;
  // 连接的状态
  String stat;
  @override
  bool operator ==(dynamic other) {
    // 判断是否是非
    if (other is! DevicesEntity) {
      return false;
    }
    if (other is DevicesEntity) {
      final DevicesEntity devicesEntity = other;
      return serial == devicesEntity.serial;
    }
    return false;
  }

  bool get isConnect => _isConnect();
  bool _isConnect() {
    return stat == 'device';
  }

  @override
  String toString() {
    return 'serial:$serial  stat:$stat';
  }

  @override
  int get hashCode => serial.hashCode;
}

class DevicesController extends GetxController {
  DevicesController() {
    poolingGetDevices();
  }
  bool getRoot = false;
  // adb是否在启动中
  bool adbIsStarting = true;

  // 这个count
  //
  // int count = 0;
  List<DevicesEntity> devicesEntitys = [];

  void clearDevices() {
    devicesEntitys.clear();
    update();
  }

  Future<void> startAdb() async {
    adbIsStarting = true;
    update();
    getRoot = await Global().process.isRoot();
    if (getRoot) {
      await Global().process.exec('su -p HOME');
    }
    Log.e('start');
    await execCmd('adb start-server');
    Log.e('end');
  }

  Future<void> poolingGetDevices() async {
    await startAdb();
    while (true) {
      // Log.e('this $this $hasListeners');
      // print('执行中');
      // print('mounted -> $mounted');
      if (Global.instance.lockAdb) {
        // print('锁住中');
        await Future<void>.delayed(const Duration(milliseconds: 100), () {});
        continue;
      }
      final String out = await execCmd('adb devices');
      Log.d(out);
      // if (count < 2) {
      //   count++;
      // }
      if (adbIsStarting) {
        adbIsStarting = false;
        update();
      }
      // if (kReleaseMode) {
      // Log.d('adb devices out -> $out');
      // }
      if (out.startsWith('List of devices')) {
        final List<String> outList = out.split('\n');
        // 删除 `List of devices attached`
        outList.removeAt(0);
        devicesEntitys.clear();
        for (final String str in outList) {
          // print('s====>$s');
          final List<String> listTmp = str.split(RegExp('\\s+'));
          final DevicesEntity devicesEntity = DevicesEntity(
            listTmp.first,
            listTmp.last,
          );
          if (!devicesEntity.serial.contains('emulator')) {
            devicesEntitys.add(devicesEntity);
          }
        }
        // for (final DevicesEntity devicesEntity in devicesEntitys) {
        //   // print(devicesEntity.serial);
        // }
        update();
      }
      await Future<void>.delayed(const Duration(milliseconds: 400), () {});
    }
  }

  DevicesEntity getDevicesByIp(String ip) {
    for (int i = 0; i < devicesEntitys.length; i++) {
      if (devicesEntitys[i].serial.contains(ip)) {
        return devicesEntitys[i];
      }
    }
    return null;
  }
}
