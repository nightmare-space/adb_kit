import 'dart:async';
import 'dart:io';
import 'package:adb_kit/adb_kit.dart';
import 'package:adb_kit/app/modules/overview/list/devices_item.dart';
import 'package:adb_library/adb_library.dart';
import 'package:dart_adb/adb.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart' hide exec;
import 'package:adb_util/adb_util.dart';

class DevicesController extends GetxController {
  DevicesController();
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  ConfigController get configController => Get.find();
  String? get password => configController.password;

  Future<void> init() async {
    ADB.setDevicePassword(password);
    await startAdb();
    ADB.addListener(handleResult);
    if (GetPlatform.isAndroid) {
      String? libPath = await AdbLibrary.getLibPath();
      ADB.setLibraryPath(libPath);
    }
    if (Platform.isIOS) return;
    ADB.startPoolingListDevices(
      duration: 1.seconds,
      onError: handleError,
    );
  }

  void handleError(String error) {
    showToast(error);
  }

  bool getRoot = false;
  // adb是否在启动中
  bool adbIsStarting = true;
  List<ADBDevice> devicesEntitys = [];
  List<ADBDevice> devicesFromDartAPI = [];

  Future<void> onPureDartADBDeviceConnect(String serial, ADBIO adbio) async {
    ADBDeviceFromDartAPI adbDevice = ADBDeviceFromDartAPI(
      '$serial:5555',
      'device',
    );
    String? model = await getDeviceProductModel(
      serial,
      usePureDart: true,
      adbio: adbio,
    );

    String? nid = await getDeviceID(
      serial,
      usePureDart: true,
      adbio: adbio,
    );
    adbDevice.nid = nid!;
    adbDevice.productModel = model;
    adbDevice.adbio = adbio;
    devicesFromDartAPI.add(adbDevice);
    HistoryController.updateHistory(
      address: adbDevice.extractIp(),
      port: adbDevice.extractPort(),
      name: adbDevice.productModel,
      uniqueId: adbDevice.nid,
    );
    updateWithAnima(devicesFromDartAPI);
  }

  void clearDevices() {
    devicesEntitys.clear();
    update();
  }

  Future<void> startAdb() async {
    // adb cli clinet adb server
    try {
      String out = await startServer();
      Log.d('adb start-server out:$out');
    } catch (e) {
      Log.e('adb start-server out:$e');
    }
    // await Future.delayed(3.seconds);
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

  Future<void> handleResult(List<ADBDevice> devices) async {
    // Log.i('handleResult -> $devices');
    letADBStarted();
    for (ADBDevice device in devices) {
      if (device.isNetworkDevice) {
        HistoryController.updateHistory(
          address: device.extractIp(),
          port: device.extractPort(),
          name: device.productModel,
          uniqueId: device.nid,
        );
      }
    }

    updateWithAnima(devices + devicesFromDartAPI);
  }

  Completer<bool>? removeLock;
  Future<void> updateWithAnima(List<ADBDevice> current) async {
    // Log.d('updateWithAnima ->$current');
    for (final ADBDevice devicesEntity in current) {
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
    for (final ADBDevice devicesEntity in List.from(devicesEntitys)) {
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

  Widget itemBuilder(ADBDevice device) {
    return DevicesItem(adbDevice: device);
  }

  void _addItem(ADBDevice devicesEntity) {
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

  ADBDevice? getDevicesByIp(String ip) {
    for (int i = 0; i < devicesEntitys.length; i++) {
      if (devicesEntitys[i].serial.contains(ip)) {
        return devicesEntitys[i];
      }
    }
    for (int i = 0; i < devicesFromDartAPI.length; i++) {
      if (devicesFromDartAPI[i].serial.contains(ip)) {
        return devicesFromDartAPI[i];
      }
    }
    return null;
  }
}
