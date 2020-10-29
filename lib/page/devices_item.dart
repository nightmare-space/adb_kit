import 'dart:io';

import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/config/envirpath.dart';
import 'package:adb_tool/global/provider/process_state.dart';
import 'package:adb_tool/utils/custom_process.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DevicesItem extends StatefulWidget {
  const DevicesItem({Key key, this.serial, this.onTap}) : super(key: key);
  // 可能是ip地址可能是设备编号
  final String serial;
  final void Function() onTap;

  @override
  _DevicesItemState createState() => _DevicesItemState();
}

class _DevicesItemState extends State<DevicesItem>
    with SingleTickerProviderStateMixin {
  String _title;
  AnimationController animationController;
  Color proColor = Colors.blue;
  Animation<double> shadow;
  double progress = 0;
  double progressMax = 1;
  // 当前在干嘛
  String curProcess = '';

  Future<void> getDeviceInfo() async {
    for (final String key in DevicesInfo.shellApi.keys) {
      if (!Config.devicesMap.containsKey(widget.serial)) {
        curProcess = '获取$key信息中...';
        if (mounted) {
          setState(() {});
        }

        final String value = (await Process.run(
          'sh',
          [
            '-c',
            '''
        adb -s ${widget.serial} shell getprop ${DevicesInfo.shellApi[key]}'''
          ],
        ))
            .stdout
            .toString()
            .trim();
        Config.devicesMap[widget.serial] = value;
      }
      progress++;
      if (progress == progressMax) {
        await animationController.forward();
        await animationController.reverse();
        proColor = Colors.green;
        curProcess = '';
        if (mounted) {
          setState(() {});
        }
      }
      if (mounted) {
        setState(() {});
      }
    }
    if (mounted) {
      setState(() {});
    }
    // for (final String str in deviceStat) {
    //   // deviceInfo[key] =
    //   if (await NiProcess.exec(
    //           'adb -s ${widget.serial} shell settings get system $str') ==
    //       '1')
    //     _list.add(true);
    //   else
    //     _list.add(false);
    //   // setState(() {});
    // }
    // print(_list);
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 500,
      ),
    );
    shadow = Tween<double>(begin: 0, end: 1).animate(animationController);
    shadow.addListener(() {
      // if (animationController.isCompleted) {
      //   animationController.reverse();
      // }
      // if (animationController.isDismissed) {
      //   animationController.forward();
      // }
      setState(() {});
    });
    isRemoteDevices();
    getDeviceInfo();
  }

  bool check = false;
  bool isRemoteDevices() {
    RegExp regExp = RegExp(
        '((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}');
    print(regExp.hasMatch(widget.serial));
  }

  @override
  Widget build(BuildContext context) {
    if (Config.devicesMap.containsKey(widget.serial))
      _title = Config.devicesMap[widget.serial];
    else {
      _title = widget.serial;
    }
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(Dimens.gap_dp8),
      child: Container(
        // decoration: BoxDecoration(
        //   gradient: LinearGradient(colors: [Colors.green.withOpacity(0.2),Colors.green.withOpacity(0.6)])
        // ),
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.gap_dp8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.deepPurple,
                          ),
                          height: Dimens.gap_dp8,
                          width: Dimens.gap_dp8,
                        ),
                        SizedBox(
                          width: Dimens.gap_dp4,
                        ),
                        Text(
                          _title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          tooltip: '点开连接',
                          icon: Icon(Icons.clear),
                          onPressed: () async {
                            Provider.of<ProcessState>(context).clear();
                            final ProcessResult result = await Process.run(
                              'sh',
                              [
                                '-c',
                                '''
                        adb disconnect ${widget.serial}
                        '''
                              ],
                            );
                            String value = result.stdout.toString().trim();
                            value += result.stderr.toString().trim();
                            print(value);
                            Provider.of<ProcessState>(context).appendOut(value);
                          },
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          curProcess,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        Radio<String>(
                          value: widget.serial,
                          groupValue: Config.curDevicesSerial,
                          onChanged: (_) {
                            Config.curDevicesSerial = widget.serial;
                            setState(() {});
                          },
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.blue.withOpacity(shadow.value),
                        offset: const Offset(0.0, 0.0), //阴影xy轴偏移量
                        blurRadius: 16.0, //阴影模糊程度
                        spreadRadius: 1.0, //阴影扩散程度
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(proColor),
                      value: progress / progressMax,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DevicesInfo {
  // 架构
  String get abi => _devicesInfo['架构'];
  // 芯片
  String get hardware => _devicesInfo['芯片'];
  // Android版本
  String get version => _devicesInfo['Android版本'];
  // 品牌
  String get manufacturer => _devicesInfo['品牌'];
  // 设备代号
  String get device => _devicesInfo['设备代号'];
  // 型号
  String get model => _devicesInfo['型号'];
  final Map<String, String> _devicesInfo = {};
  Map get devicesInfo => _devicesInfo;
  static Map<String, String> shellApi = <String, String>{
    // '架构': 'ro.product.cpu.abi',
    // '芯片': 'ro.boot.hardware',
    // 'Android版本': 'ro.build.version.release',
    // '品牌': 'ro.product.manufacturer',
    // '设备代号': 'ro.product.device',
    '型号': 'ro.product.model',
  };
  final List<String> _deviceStat = <String>[
    'show_touches',
    'pointer_location',
  ];
  void setValue(String key, String value) {
    _devicesInfo[key] = value;
  }

  String getValue(
    String key,
  ) {
    if (_devicesInfo.containsKey(key)) {
      return _devicesInfo[key];
    }
    return '';
  }
}

class DevicesInfoDialog extends StatelessWidget {
  const DevicesInfoDialog({Key key, this.devicesInfo}) : super(key: key);

  final DevicesInfo devicesInfo;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        height: 300,
        child: Material(
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
            child: Column(
              children: [
                for (var key in DevicesInfo.shellApi.keys)
                  Row(
                    children: [
                      Text(key),
                      Text(
                        devicesInfo.getValue(key),
                      ),
                    ],
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
