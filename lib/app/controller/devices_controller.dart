import 'dart:async';
import 'package:adb_kit/app/modules/overview/list/devices_item.dart';
import 'package:adb_library/adb_library.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'history_controller.dart';

class DevicesEntity {
  DevicesEntity(this.serial, this.stat);
  static String modelGetKey = 'ro.product.model';
  // 有可能是ip或者设备序列号
  final String serial;
  // ro.product.model
  String? productModel;
  // connect stat
  String stat;
  String uniqueId = '';

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
    return 'serial:$serial stat:$stat';
  }

  @override
  int get hashCode => serial.hashCode;
}

class DevicesController extends GetxController {
  DevicesController();
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  Future<void> init() async {
    await startAdb();
    AdbUtil.addListener(handleResult);
    if (GetPlatform.isAndroid) {
      String? libPath = await AdbLibrary.getLibPath();
      AdbUtil.setLibraryPath(libPath);
    }
    AdbUtil.startPoolingListDevices(
      duration: const Duration(seconds: 1),
    );
  }

  List<DevicesEntity> otgDevices = [];

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
    // 显示一会动画
    // await Future.delayed(const Duration(milliseconds: 300));
    update();
    // getRoot = await Global().process.isRoot();
    // if (getRoot) {
    //   await Global().process.exec('su -p HOME');
    // }
    // adb cli clinet adb server
    try {
      String adbStartBin = 'adb';
      String out = await execCmd('$adbStartBin start-server');
      Log.d('adb start-server out:$out');
      // ignore: empty_catches
    } catch (e) {
      Log.d('adb start-server out:${(e as dynamic).message}');
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

  // Model Cache
  // Some device like xiaomi can't get model name by `ro.product.marketname`
  Map<String, String> modelCache = {
    // '23127PN0CC': 'Xiaomi 14',
  };
  Future<void> handleResult(String? data) async {
    letADBStarted();
    if (data!.startsWith('List of devices')) {
      final List<String> outList = data.split('\n');
      // 删除 `List of devices attached`
      // Rmove `List of devices attached`
      outList.removeAt(0);
      final List<DevicesEntity> tmpDevices = [];
      for (final String str in outList) {
        final List<String> listTmp = str.trim().split(RegExp('\\s+'));
        final DevicesEntity devicesEntity = DevicesEntity(listTmp.first, listTmp.last);
        if (devicesEntity.isConnect) {
          String? model;
          if (modelCache.containsKey(listTmp.first)) {
            model = modelCache[listTmp.first];
          } else {
            try {
              model = await execCmd('$adb -s ${listTmp.first} shell getprop ro.product.marketname');
              if (model.trim().isEmpty) {
                model = await execCmd('$adb -s ${listTmp.first} shell getprop ${DevicesEntity.modelGetKey}');
              }
              modelCache[listTmp.first] = model;
            } catch (e) {
              Log.w(RuntimeEnvir.path);
              Log.e('get model error : $e');
            }
          }
          String id;
          String nidPath = '/data/local/tmp/nid';
          try {
            // nightmare id, use to cache history
            id = await execCmd2([adb, '-s', listTmp.first, 'shell', 'cat', nidPath]);
          } catch (e) {
            Log.i('error -> $e');
            id = shortHash(() {}).toString();
            try {
              await execCmd2([adb, '-s', listTmp.first, 'shell', 'echo', id, '>$nidPath']);
            } catch (e) {
              Log.i('write id error -> ${e.toString().trim()}');
            }
          }
          devicesEntity.uniqueId = id;
          devicesEntity.productModel = model;
          if (model != null) {
            final List<String> tmp = devicesEntity.serial.split(':');
            final String address = tmp[0];
            HistoryController.updateHistory(name: model, address: address, uniqueId: id);
            tmpDevices.add(devicesEntity);
          }
        }
      }
      for (final DevicesEntity entity in otgDevices) {
        tmpDevices.add(entity);
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
