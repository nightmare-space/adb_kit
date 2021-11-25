import 'dart:async';

import 'package:adb_tool/app/modules/overview/list/devices_item.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/utils/plugin_util.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare_view/termare_view.dart';

import 'history_controller.dart';

class DevicesEntity {
  DevicesEntity(this.serial, this.stat);
  static String modelGetKey = 'ro.product.model';
  // 有可能是ip或者设备序列号
  final String serial;
  // ro.product.model
  String productModel;
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
    return stat == 'device' || stat == 'OTG';
  }

  bool get isOTG => _isOTG();
  bool _isOTG() {
    return stat == 'OTG';
  }

  @override
  String toString() {
    return 'serial:$serial  stat:$stat';
  }

  @override
  int get hashCode => serial.hashCode;
}

// ro.product.model
class DevicesController extends GetxController {
  DevicesController() {
    init();
  }
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();

  Future<void> init() async {
    PluginUtil.addHandler((call) {
      if (call.method == 'DeviceAttach') {
        final DevicesEntity entity = DevicesEntity(
          '',
          'OTG',
        );
        entity.productModel = call.arguments.toString();
        otgDevices.add(entity);
      } else if (call.method == 'DeviceDetach') {
        Log.e('DeviceDetach');
        otgDevices.clear();
      } else if (call.method == 'output') {
        otgTerm.write(call.arguments.toString());
      }
    });

    await startAdb();
    AdbUtil.addListener(handleResult);
    AdbUtil.startPoolingListDevices();
  }

  List<DevicesEntity> otgDevices = [];

  bool getRoot = false;
  // adb是否在启动中
  bool adbIsStarting = true;
  final TermareController otgTerm = TermareController(
    fontFamily: '${Config.flutterPackage}MenloforPowerline',
    theme: TermareStyles.macos.copyWith(
      backgroundColor: AppColors.background,
    ),
  );
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
    // 显示一会动画
    await Future.delayed(const Duration(milliseconds: 300));
    update();
    getRoot = await Global().process.isRoot();
    if (getRoot) {
      await Global().process.exec('su -p HOME');
    }
    // Log.e('start');
    try {
      await execCmd('adb start-server');
      // ignore: empty_catches
    } catch (e) {}
    // Log.e('end');
  }

  // 这是model的缓存
  Map<String, String> modelCache = {};
  Future<void> handleResult(String data) async {
    Log.d('data -> $data');
    // if (count < 2) {
    //   count++;
    // }
    if (adbIsStarting) {
      adbIsStarting = false;
      Log.w('adbIsStarting = false');
      update();
    }
    // if (kReleaseMode) {
    // Log.d('adb devices out -> $out');
    // }
    if (data.startsWith('List of devices')) {
      final List<String> outList = data.split('\n');
      // 删除 `List of devices attached`
      outList.removeAt(0);
      final List<DevicesEntity> tmpDevices = [];
      for (final String str in outList) {
        final List<String> listTmp = str.split(RegExp('\\s+'));
        final DevicesEntity devicesEntity = DevicesEntity(
          listTmp.first,
          listTmp.last,
        );
        // Log.w('获取${listTmp.first}信息...');
        String model;
        if (modelCache.containsKey(listTmp.first)) {
          model = listTmp.first;
        } else {
          try {
            model = await execCmd(
              'adb -s ${listTmp.first} shell getprop ${DevicesEntity.modelGetKey}',
            );
          } catch (e) {
            Log.w(e);
          }
        }
        devicesEntity.productModel = model;
        if (!devicesEntity.serial.contains('emulator') && model != null) {
          // 更新这个设备的历史记录的设备名
          final List<String> tmp = devicesEntity.serial.split(':');
          final String address = tmp[0];
          HistoryController.updateHistory(
            name: model,
            address: address,
          );
          tmpDevices.add(devicesEntity);
        }
      }
      otgDevices.forEach((value) {
        tmpDevices.add(value);
      });
      updateWithAnima(tmpDevices);
    }
  }

  Completer<bool> removeLock;
  Future<void> updateWithAnima(List<DevicesEntity> current) async {
    // Log.d('updateWithAnima ->$current');
    for (final DevicesEntity devicesEntity in current) {
      if (!devicesEntitys.contains(devicesEntity)) {
        // 如果当前列表不包含controller列表的item
        print('devicesEntity ->$devicesEntity');
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
      await removeLock.future;
    }
    // 遍历当前state的list
    for (final DevicesEntity devicesEntity in List.from(devicesEntitys)) {
      // Log.w('devicesEntity -> $devicesEntity');

      if (!current.contains(devicesEntity)) {
        removeLock = Completer<bool>();
        print('需要删除devicesEntity ->$devicesEntity');
        final int deleteIndex = devicesEntitys.indexOf(devicesEntity);
        Future.delayed(const Duration(milliseconds: 300), () {
          update();
          removeLock.complete();
        });
        devicesEntitys.removeAt(deleteIndex);
        listKey.currentState.removeItem(
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
      listKey.currentState.insertItem(
        index,
        duration: const Duration(
          milliseconds: 300,
        ),
      );
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
