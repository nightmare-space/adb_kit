import 'package:adb_tool/utils/custom_process.dart';
import 'package:flutter/material.dart';

class DevicesList extends StatefulWidget {
  @override
  _DevicesListState createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {
  @override
  void initState() {
    super.initState();

    getDevices();
  }

  List<String> generate(List<String> pre) {
    List<String> tmp = [];
    for (String s in pre) {
      // print('s====>$s');
      final String devicesEntity = s.split(RegExp('\\s+')).first;
      // print(devicesEntity.hashCode);
      tmp.add(devicesEntity);
    }
    return tmp;
  }

  List<String> devicesEntitys = [];
  Future<void> getDevices() async {
    while (mounted) {
      final String out = (await NiProcess.exec('adb devices')).trim();
      // print('------------------');
      // 说明adb服务开启了
      if (out.startsWith('List of devices')) {
        final List<String> tmp = out.split('\n')..removeAt(0);
        devicesEntitys = generate(tmp);
        setState(() {});
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (devicesEntitys.isEmpty)
          const Text(
            '未发现设备',
            style: TextStyle(color: Colors.grey),
          ),
      ],
    );
  }
}
