import 'package:adb_tool/page/developer_tool.dart';
import 'package:adb_tool/page/devices_item.dart';
import 'package:adb_tool/utils/custom_process.dart';
import 'package:flutter/material.dart';

class DevicesEntity {
  DevicesEntity(this.serial, this.stat);
  // 有可能是ip或者设备序列号
  final String serial;
  // 连接的状态
  final String stat;
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
  }

  @override
  int get hashCode => serial.hashCode;
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
      position: _animation.drive(CurveTween(curve: Curves.easeIn)).drive(
          Tween<Offset>(begin: const Offset(1, 0), end: const Offset(0, 0))),
      child: DevicesItem(
        onTap: () {
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
      final String out = (await NiProcess.exec('adb devices')).trim();
      // print('------------------');
      // 说明adb服务开启了
      if (out.startsWith('List of devices')) {
        final List<String> tmp = out.split('\n')..removeAt(0);
        final List<String> addressList = [];
        print(tmp);
        // devicesEntitys.clear();
        for (final String str in tmp) {
          // print('s====>$s');
          final List<String> listTmp = str.split(RegExp('\\s+'));
          final DevicesEntity devicesEntity =
              DevicesEntity(listTmp.first, listTmp.last);
          // print(devicesEntity.hashCode);
          addressList.add(listTmp.first);
          if (!devicesEntitys.contains(devicesEntity)) {
            _addItem(devicesEntity);
            // devicesEntitys.add(devicesEntity);
          }
        }
        print('addressList===>$addressList');
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
          print(devicesEntity.serial);
        }
        // devicesEntitys.removeWhere((element) {
        //   bool contains = addressList.contains(element.serial);
        //   _removeItem(element);
        //   return !contains;
        // });
        // await Future<void>.delayed(Duration(milliseconds: 300));
        // devicesEntitys = generate(tmp);
        // print('devicesEntitys->${devicesEntitys}');

        // for(final devicesEntity in devicesEntitys){
        //   bool containes=false;
        //   for(final s in tmp){
        //     if(s.startsWith(devicesEntity.ip)){
        //       containes=true;
        //       break;
        //     }
        //   }
        //   print(containes);
        //   print(devicesEntity.ip);
        //   if(!containes){
        //     devicesEntitys.remove(devicesEntity);
        //     setState(() {

        //     });
        //   }
        // }
        // print('------------------');
        // print(tmp);
      }
      await Future<void>.delayed(const Duration(milliseconds: 50), () {});
    }
  }

  int i = 0;
  void addItem() {
    final int _index = devicesEntitys.length;
    devicesEntitys.insert(_index, DevicesEntity('$i', 'stat'));
    setState(() {});
    _listKey.currentState.insertItem(_index);
    i++;
  }

  void removeItem() {
    final int _index = devicesEntitys.length - 1;
    _listKey.currentState.removeItem(
        _index,
        (context, animation) =>
            _buildItem(DevicesEntity('7919c2f1', 'stat'), animation),
        duration: const Duration(
          seconds: 3,
        ));
    devicesEntitys.removeAt(_index);
    setState(() {});
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
            itemBuilder:
                (BuildContext context, int index, Animation animation) {
              return _buildItem(devicesEntitys[index], animation);
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
