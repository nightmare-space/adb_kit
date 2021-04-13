import 'package:adb_tool/app/modules/home/controllers/devices_controller.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/page/developer_tool/developer_tool.dart';
import 'package:custom_log/custom_log.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import 'devices_item.dart';

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

  bool connect() {
    return stat == 'device';
  }

  @override
  String toString() {
    return 'serial:$serial  stat:$stat';
  }

  @override
  int get hashCode => serial.hashCode;
}

class DevicesList extends StatefulWidget {
  @override
  _DevicesListState createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<DevicesEntity> devicesEntitys = [];
  final DevicesController controller = Get.find<DevicesController>();

  @override
  void initState() {
    super.initState();
    devicesEntitys = List.from(controller.devicesEntitys);
    Log.d(controller.devicesEntitys);
    Log.d(devicesEntitys);
    controller.addListener(updateList);
    Future.delayed(const Duration(milliseconds: 100), () {
      controller.poolingGetDevices();
    });
  }

  @override
  void dispose() {
    controller.removeListener(updateList);
    super.dispose();
  }

  void updateList() {
    // infos.clear();
    for (final DevicesEntity devicesEntity in controller.devicesEntitys) {
      // Log.i('devicesEntity -> $devicesEntity');
      // if (devicesEntity.serial.contains('emulator')) {
      //   Log.e('devicesEntity.serial 包含 emulator');
      //   // TODO，在将来可能会有bug
      //   continue;
      // }
      if (!devicesEntitys.contains(devicesEntity)) {
        print('devicesEntity ->$devicesEntity');
        _addItem(devicesEntity);
      }
    }

    // 遍历当前state的list
    for (final DevicesEntity devicesEntity in List.from(devicesEntitys)) {
      // Log.w('devicesEntity -> $devicesEntity');
      // Log.e(scripts.indexOf(script));
      //
      if (!controller.devicesEntitys.contains(devicesEntity)) {
        print('需要删除devicesEntity ->$devicesEntity');
        final int deleteIndex = devicesEntitys.indexOf(devicesEntity);
        Future.delayed(const Duration(milliseconds: 300), () {
          setState(() {});
        });
        devicesEntitys.removeAt(deleteIndex);
        _listKey.currentState.removeItem(
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

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  Future<void> _onAfterRendering(Duration timeStamp) async {
    // deviceEntitys.addListener(() {
    //   // pritn
    // });
  }

  void _addItem(DevicesEntity devicesEntity) {
    final int index = devicesEntitys.length;
    devicesEntitys.add(devicesEntity);
    setState(() {});
    _listKey.currentState.insertItem(
      index,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 48.0 * devicesEntitys.length,
              child: AnimatedList(
                // physics: NeverScrollableScrollPhysics(),
                shrinkWrap: false,
                padding: const EdgeInsets.only(top: 0),
                key: _listKey,
                initialItemCount: devicesEntitys.length,
                itemBuilder: (
                  BuildContext context,
                  int index,
                  Animation<double> animation,
                ) {
                  final DevicesEntity devicesEntity = devicesEntitys[index];
                  return SlideTransition(
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
                  );
                },
              ),
            ),
            if (controller.devicesEntitys.isEmpty)
              const Text(
                '未发现设备',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ],
    );
  }

  Widget itemBuilder(DevicesEntity entity) {
    final DevicesEntity devicesEntity = entity;
    return DevicesItem(
      onTap: () async {
        if (!devicesEntity.connect()) {
          showToast('设备未正常连接');
          return;
        }
        // print(devicesEntity.serial);
        // if (Platform.isAndroid) {
        //   Global.instance.lockAdb = true;
        //   const MethodChannel channel = MethodChannel('scrcpy');
        //  String result=await channel.invokeMethod<String>('-s ${devicesEntity.serial}');
        //  print('result -> $result');
        // } else
        Navigator.of(
          context,
        ).push<void>(
          MaterialPageRoute(
            builder: (_) {
              return DeveloperTool(
                serial: devicesEntity.serial,
              );
            },
          ),
        );
      },
      devicesEntity: devicesEntity,
    );
  }
}
