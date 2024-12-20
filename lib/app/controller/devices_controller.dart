import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:adb_kit/adb_kit.dart';
import 'package:adb_kit/app/modules/overview/list/devices_item.dart';
import 'package:adb_kit/config/config.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:adb_kit/utils/utils.dart';
import 'package:adb_library/adb_library.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart' hide exec;
import 'config_controller.dart';
import 'history_controller.dart';
import 'package:adb_util/adb_util_flutter.dart';

class ADBDevice {}

/// TODO 把这个下放到 adb_util，无界也会依赖这个
/// ADB.addListener 直接吐 List<DevicesEntity>
class DevicesEntity {
  DevicesEntity(this.serial, this.stat);
  static DevicesEntity parse(String data) {
    final tmp = data.trim().split(RegExp('\\s+'));
    final device = DevicesEntity(tmp.first, tmp.last);
    return device;
  }

  static String modelGetKey = 'ro.product.model';
  // 有可能是ip或者设备序列号
  final String serial;
  // ro.product.model
  String? productModel;
  // connect stat
  String stat;
  String uniqueId = '';

  // 判断 serial 是否是 ipv4/ipv6

  bool get isIp {
    return serial.contains(':');
  }

  @override
  bool operator ==(Object other) {
    // 判断是否是非
    if (other is! DevicesEntity) {
      return false;
    }
    final DevicesEntity devicesEntity = other;
    return serial == devicesEntity.serial;
  }

  bool get isConnect => _isConnect();
  bool _isConnect() {
    return stat == 'device';
  }

  @override
  String toString() {
    return 'DevicesEntity{serial: $serial, stat: $stat}';
  }

  @override
  int get hashCode => serial.hashCode;

  String? get password => Get.find<ConfigController>().password;
}

class DevicesController extends GetxController {
  DevicesController();
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  ConfigController get configController => Get.find();
  String get password => configController.password;

  Future<void> init() async {
    await startAdb();
    ADB.addListener(handleResult);
    if (GetPlatform.isAndroid) {
      String? libPath = await AdbLibrary.getLibPath();
      ADB.setLibraryPath(libPath);
    }
    ADB.startPoolingListDevices(duration: 1.seconds);
  }

  bool getRoot = false;
  // adb是否在启动中
  bool adbIsStarting = true;
  List<DevicesEntity> devicesEntitys = [];

  void clearDevices() {
    devicesEntitys.clear();
    update();
  }

  Future<void> startAdb() async {
    adbIsStarting = true;
    update();
    // adb cli clinet adb server
    try {
      String out = await startServer();
      Log.d('adb start-server out:$out');
    } catch (e) {
      Log.e('adb start-server out:$e');
    }
    letADBStarted();
    // final List<String> devices = await ADBFind.getLANDevices();
    // for (String ip in devices) {
    //   try {
    //     await AdbUtil.connectDevices(ip);
    //   } on AdbException catch (e) {
    //     Log.w('自动连接设备异常 : $e');
    //   }
    // }
  }

  void letADBStarted() {
    if (adbIsStarting) {
      adbIsStarting = false;
      update();
    }
  }

  Future<void> handleResult(String? data) async {
    // Log.i('handleResult -> $data');
    letADBStarted();
    if (data!.startsWith('List of devices')) {
      final List<String> outList = data.split('\n');
      // 删除 `List of devices attached`
      // Rmove `List of devices attached`
      outList.removeAt(0);
      final List<DevicesEntity> tmpDevices = [];
      for (final String str in outList) {
        final DevicesEntity device = DevicesEntity.parse(str);
        if (!device.isConnect) {
          continue;
        }
        String? model;
        String? nid;
        try {
          model = await getDeviceProductModel(device.serial, password: password);
          nid = await getDeviceID(device.serial, password: password);
        } catch (e) {
          continue;
        }
        device.productModel = model;
        // just network device need to save history
        if (model != null && nid != null && device.isIp) {
          device.uniqueId = nid;
          final List<String> tmp = device.serial.split(':');
          final address = tmp[0];
          final port = tmp[1];
          HistoryController.updateHistory(
            name: model,
            address: address,
            uniqueId: nid,
            port: port,
          );
        }
        tmpDevices.add(device);
      }
      updateWithAnima(tmpDevices);
    }
  }

  Completer<bool>? removeLock;
  Future<void> updateWithAnima(List<DevicesEntity> current) async {
    // Log.d('updateWithAnima ->$current');
    for (final DevicesEntity devicesEntity in current) {
      if (!devicesEntitys.contains(devicesEntity)) {
        // 如果当前列表不包含controller列表的item
        Log.i('Add Devices -> $devicesEntity');
        _addItem(devicesEntity);
      } else {
        final int index = devicesEntitys.indexOf(devicesEntity);
        if (devicesEntitys[index].stat != devicesEntity.stat) {
          devicesEntitys[index] = devicesEntity;
          update();
        }
      }
    }
    if (removeLock != null) {
      await removeLock!.future;
    }
    // 遍历当前state的list
    for (final DevicesEntity devicesEntity in List.from(devicesEntitys)) {
      // Log.w('devicesEntity -> $devicesEntity');

      if (!current.contains(devicesEntity)) {
        removeLock = Completer<bool>();
        Log.v('Remove DevicesEntity ->$devicesEntity');
        final int deleteIndex = devicesEntitys.indexOf(devicesEntity);
        Future.delayed(const Duration(milliseconds: 300), () {
          update();
          removeLock!.complete(true);
        });
        devicesEntitys.removeAt(deleteIndex);
        listKey.currentState!.removeItem(
          deleteIndex,
          (context, animation) => SlideTransition(
            position: animation
                .drive(
                  CurveTween(curve: Curves.easeIn),
                )
                .drive(
                  Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: const Offset(0, 0),
                  ),
                ),
            child: itemBuilder(devicesEntity),
          ),
          duration: const Duration(milliseconds: 300),
        );
        // devicesEntitys.setRange(start, end, iterable)
      }
    }
  }

  Widget itemBuilder(DevicesEntity entity) {
    return DevicesItem(
      devicesEntity: entity,
    );
  }

  void _addItem(DevicesEntity devicesEntity) {
    final int index = devicesEntitys.length;
    devicesEntitys.add(devicesEntity);
    update();
    if (listKey.currentContext != null) {
      listKey.currentState!.insertItem(
        index,
        duration: const Duration(
          milliseconds: 300,
        ),
      );
    }
  }

  DevicesEntity? getDevicesByIp(String ip) {
    for (int i = 0; i < devicesEntitys.length; i++) {
      if (devicesEntitys[i].serial.contains(ip)) {
        return devicesEntitys[i];
      }
    }
    return null;
  }
}
