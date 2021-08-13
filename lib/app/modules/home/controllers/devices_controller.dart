import 'dart:io';

import 'package:adb_tool/global/instance/global.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

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
    init();
  }

  Future<void> init() async {
    await startAdb();
    AdbUtil.addListener(handleResult);
    AdbUtil.startPoolingListDevices();
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

  Future<void> handleResult(String data) async {
    // Log.d('data -> $data');
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
    if (data.startsWith('List of devices')) {
      final List<String> outList = data.split('\n');
      // 删除 `List of devices attached`
      outList.removeAt(0);
      devicesEntitys.clear();
      for (final String str in outList) {
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
