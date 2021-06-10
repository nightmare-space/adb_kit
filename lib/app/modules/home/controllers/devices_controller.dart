import 'dart:io';

import 'package:adb_tool/app/modules/overview/list/devices_list.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class DevicesController extends GetxController {
  DevicesController() {
    poolingGetDevices();
  }
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  List<DevicesEntity> devicesEntitys = [];

  Future<void> poolingGetDevices() async {
    while (hasListeners) {
      // Log.e('this $this $hasListeners');
      // print('执行中');
      // print('mounted -> $mounted');
      if (Global.instance.lockAdb) {
        // print('锁住中');
        await Future<void>.delayed(const Duration(milliseconds: 100), () {});
        continue;
      }
      String out;
      // Log.i('adb devices');
      if (kIsWeb) {
        out = '''
List of devices attached
192.168.213.32:5555	device
emulator-5554	device
''';
        out = out.trim();
      } else if (Platform.isWindows) {
        String stderr;
        String stdout;
        final ProcessResult result = await Process.run(
          'adb',
          ['devices'],
          environment: PlatformUtil.environment(),
          runInShell: true,
        );
        stdout = result.stdout.toString();
        stderr = result.stderr.toString();
        out = stdout.trim();
        // print('stderr->$stderr');
        // print('stdout->$stdout');
      } else {
        // NiProcess 是一个自定义的 Process，因为可能存在使用一个带 root
        // 权限的流
        out = (await NiProcess.exec('adb devices')).trim();
      }
      // 说明adb服务开启了
      if (out.startsWith('List of devices')) {
        final List<String> outList = out.split('\n');
        // 删除 List of devices attached
        outList.removeAt(0);
        // final List<String> addressList = [];
        // Log.e('outList->$outList');
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
      await Future<void>.delayed(const Duration(milliseconds: 300), () {});
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
