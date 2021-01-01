import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/global/provider/process_info.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:provider/provider.dart';

import 'devices_list.dart';

class DevicesItem extends StatefulWidget {
  const DevicesItem({Key key, this.devicesEntity, this.onTap})
      : super(key: key);
  // 可能是ip地址可能是设备编号
  final DevicesEntity devicesEntity;
  final void Function() onTap;

  @override
  _DevicesItemState createState() => _DevicesItemState();
}

class _DevicesItemState extends State<DevicesItem>
    with TickerProviderStateMixin {
  String _title;
  AnimationController animationController;
  AnimationController progressAnimaCTL;
  Color proColor = Colors.blue;
  Animation<double> shadow;
  double progress = 0;
  double progressMax = 1;
  // 当前在干嘛
  String curProcess = '';

  Future<void> getDeviceInfo() async {
    for (final String key in DevicesInfo.shellApi.keys) {
      if (!Config.devicesMap.containsKey(widget.devicesEntity.serial)) {
        curProcess = '获取$key信息中...';
        if (mounted) {
          setState(() {});
        }

        final String value = await exec(
            'adb -s ${widget.devicesEntity.serial} shell getprop ${DevicesInfo.shellApi[key]}');
        print('value->$value');

        if (value.isNotEmpty && value.length <= 10)
          Config.devicesMap[widget.devicesEntity.serial] = value;
      }
      progress++;
      if (progress == progressMax) {
        await animationController?.forward();
        await Future<void>.delayed(const Duration(milliseconds: 300));
        await animationController?.reverse();
        proColor = Colors.blue;
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
    //           'adb -s ${widget.devicesEntity.serial} shell settings get system $str') ==
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
    progressAnimaCTL = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 500,
      ),
    );
    progressAnimaCTL.forward();
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
    getDeviceInfo();
  }

  bool check = false;
  @override
  void dispose() {
    animationController.dispose();
    progressAnimaCTL.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (Config.devicesMap.containsKey(widget.devicesEntity.serial)) {
      // print('object');
      _title = Config.devicesMap[widget.devicesEntity.serial];
    } else {
      _title = widget.devicesEntity.serial;
    }
    return InkWell(
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
                        SizedBox(
                          width: Dimens.gap_dp8,
                        ),
                        Text(
                          widget.devicesEntity.stat,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        if (isAddress(widget.devicesEntity.serial))
                          IconButton(
                            tooltip: '断开连接',
                            icon: const Icon(Icons.clear),
                            onPressed: () async {
                              Provider.of<ProcessState>(context).clear();
                              final String result = await exec(
                                  'adb disconnect ${widget.devicesEntity.serial}');
                              Provider.of<ProcessState>(context).appendOut(
                                result,
                              );
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
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.black87,
                          ),
                          onPressed: widget.onTap,
                        ),
                        // Radio<String>(
                        //   value: widget.devicesEntity.serial,
                        //   groupValue: Config.curDevicesSerial,
                        //   onChanged: (_) {
                        //     Config.curDevicesSerial =
                        //         widget.devicesEntity.serial;
                        //     setState(() {});
                        //   },
                        // )
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
                      value: progressAnimaCTL.value * progress / progressMax,
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
  // final List<String> _deviceStat = <String>[
  //   'show_touches',
  //   'pointer_location',
  // ];
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
