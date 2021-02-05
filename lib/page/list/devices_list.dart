import 'dart:io';

import 'package:adb_tool/page/developer_tool/developer_tool.dart';
import 'package:adb_tool/page/list/devices_item.dart';
import 'package:custom_log/custom_log.dart';
import 'package:flutter/material.dart';
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

  @override
  int get hashCode => serial.hashCode;
  bool connect() {
    return stat == 'device';
  }

  @override
  String toString() {
    return 'serial:$serial  stat:$stat';
  }
}

class DevicesList extends StatefulWidget {
  @override
  _DevicesListState createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {
  List<DevicesEntity> devicesEntitys = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  @override
  void initState() {
    super.initState();
    getDevices();
  }

  void _addItem(DevicesEntity devicesEntity) {
    final int _index = devicesEntitys.length;
    devicesEntitys.insert(_index, devicesEntity);
    setState(() {});
    _listKey.currentState.insertItem(_index);
  }

  Widget _buildItem(DevicesEntity devicesEntity, Animation _animation) {
    return SlideTransition(
      position: _animation
          .drive(CurveTween(
            curve: Curves.easeIn,
          ))
          .drive(
            Tween<Offset>(
              begin: const Offset(1, 0),
              end: const Offset(0, 0),
            ),
          ),
      child: DevicesItem(
        onTap: () {
          print('object');
          // return;
          Navigator.of(
            context,
          ).push<void>(
            MaterialPageRoute(
              builder: (_) {
                return DeveloperTool(
                  serial: devicesEntity.serial,
                  providerContext: context,
                );
              },
            ),
          );
        },
        devicesEntity: devicesEntity,
      ),
    );
  }

  Future<void> getDevices() async {
    while (mounted) {
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
      // Log.w(out);
      // print('------------------');
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
            _addItem(devicesEntity);
            // devicesEntitys.add(devicesEntity);
          } else {
            // 更新数据
            devicesEntitys.forEach((element) {
              if (element == devicesEntity) {
                // 找到元素
                if (element.stat != devicesEntity.stat) {
                  element.stat = devicesEntity.stat;
                  setState(() {});
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
            print('要删除的====>${devicesEntitys[curIndex].serial}');
            final DevicesEntity devicesEntity = devicesEntitys[curIndex];
            _listKey.currentState.removeItem(
              curIndex,
              (context, animation) => _buildItem(
                devicesEntity,
                animation,
              ),
              duration: const Duration(milliseconds: 300),
            );

            devicesEntitys.removeAt(curIndex);
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {});
            });
            // setState(() {});
            curIndex--;
            length--;
          }
        }
        for (final DevicesEntity devicesEntity in devicesEntitys) {
          // print(devicesEntity.serial);
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 100), () {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (devicesEntitys.isEmpty)
          const Text(
            '未发现设备',
            style: TextStyle(color: Colors.grey),
          ),
        SizedBox(
          height: 48.0 * devicesEntitys.length,
          child: AnimatedList(
            shrinkWrap: false,
            padding: const EdgeInsets.only(top: 0),
            key: _listKey,
            initialItemCount: devicesEntitys.length,
            itemBuilder: (
              BuildContext context,
              int index,
              Animation animation,
            ) {
              return _buildItem(
                devicesEntitys[index],
                animation,
              );
            },
          ),
        ),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   crossAxisAlignment: CrossAxisAlignment.center,
        //   children: <Widget>[
        //     FloatingActionButton(
        //       onPressed: () => addItem(),
        //       child: Icon(Icons.add),
        //     ),
        //     SizedBox(
        //       width: 60,
        //     ),
        //     FloatingActionButton(
        //       onPressed: () => removeItem(),
        //       child: Icon(Icons.remove),
        //     ),
        //   ],
        // ),
        // for (DevicesEntity devicesEntity in devicesEntitys)
        //   DevicesItem(
        //     onTap: () {
        //       Navigator.of(
        //         context,
        //       ).push<void>(
        //         MaterialPageRoute(
        //           builder: (_) {
        //             return DeveloperTool(
        //               serial: devicesEntity.serial,
        //               providerContext: context,
        //             );
        //           },
        //         ),
        //       );
        //     },
        //     devicesEntity: devicesEntity,
        //   ),
        // const DevicesItem(
        //   serial: '192.168.43.1:5555',
        // ),
        // const DevicesItem(
        //   serial: '192.168.43.209:5555',
        // ),
      ],
    );
  }
}
