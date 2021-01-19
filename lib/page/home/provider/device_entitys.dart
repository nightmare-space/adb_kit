import 'dart:io';

import 'package:adb_tool/config/global.dart';
import 'package:adb_tool/page/list/devices_list.dart';
import 'package:custom_log/custom_log.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
// 仅仅用于MaterialApp上的更新

class DeviceEntitys extends ChangeNotifier {
  DeviceEntitys() {
    // getDevices();
  }
  List<DevicesEntity> devicesEntitys = [];

  Future<void> getDevices() async {
    while (true) {
      // print('执行中');
      // print('mounted -> $mounted');
      if (Global.instance.lockAdb) {
        // print('锁住中');
        await Future<void>.delayed(const Duration(milliseconds: 100), () {});
        continue;
        ;
      }
      String out;
      if (Platform.isWindows) {
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
        out = (await NiProcess.exec('adb devices')).trim();
      }
      // 说明adb服务开启了
      if (out.startsWith('List of devices')) {
        final List<String> tmp = out.split('\n')..removeAt(0);
        final List<String> addressList = [];
        // print(tmp);
        // devicesEntitys.clear();
        for (final String str in tmp) {
          // print('s====>$s');
          final List<String> listTmp = str.split(RegExp('\\s+'));
          final DevicesEntity devicesEntity =
              DevicesEntity(listTmp.first, listTmp.last);
          // print(devicesEntity.hashCode);
          addressList.add(listTmp.first);
          // 如果devicesEntitys没有这个设备，就需要更新
          if (!devicesEntitys.contains(devicesEntity)) {
            final int _index = devicesEntitys.length;
            devicesEntitys.insert(_index, devicesEntity);
          } else {
            // 更新数据
            devicesEntitys.forEach((element) {
              if (element == devicesEntity) {
                // 找到元素
                if (element.stat != devicesEntity.stat) {
                  element.stat = devicesEntity.stat;
                  notifyListeners();
                }
                // print('pre->$element');
                // print('devicesEntity->$devicesEntity');
              }
            });
          }
        }
        // print('addressList===>$addressList');
        int length = devicesEntitys.length;
        int curIndex = 0;
        for (; curIndex < length; curIndex++) {
          if (!addressList.contains(devicesEntitys[curIndex].serial)) {
            Log.v(
              '要删除的====>${devicesEntitys[curIndex].serial}',
            );
            final DevicesEntity devicesEntity = devicesEntitys[curIndex];
            // _listKey.currentState.removeItem(
            //   curIndex,
            //   (context, animation) => _buildItem(
            //     devicesEntity,
            //     animation,
            //   ),
            //   duration: const Duration(milliseconds: 300),
            // );

            devicesEntitys.removeAt(curIndex);

            // setState(() {});
            curIndex--;
            length--;
          }
        }
        notifyListeners();
        for (final DevicesEntity devicesEntity in devicesEntitys) {
          Log.e('-------------');
          Log.e(devicesEntity);
          // print(devicesEntity.serial);
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 500), () {});
    }
  }
}
