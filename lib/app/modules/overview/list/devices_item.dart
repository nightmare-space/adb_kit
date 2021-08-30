import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/modules/developer_tool/developer_tool.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/utils/dex_server.dart';
import 'package:adbutil/adbutil.dart';
import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:signale/signale.dart';

class DevicesItem extends StatefulWidget {
  const DevicesItem({
    Key key,
    this.devicesEntity,
  }) : super(key: key);
  // 可能是ip地址可能是设备编号
  final DevicesEntity devicesEntity;

  @override
  _DevicesItemState createState() => _DevicesItemState();
}

class _DevicesItemState extends State<DevicesItem>
    with TickerProviderStateMixin {
  String _title;
  AnimationController animationController;
  AnimationController progressAnimaCTL;
  Animation<double> shadow;
  double progress = 0;
  double progressMax = 1;
  // 当前在干嘛
  String curProcess;

  Future<void> getDeviceInfo() async {
    await Future.delayed(const Duration(milliseconds: 100), () {
      progressAnimaCTL.forward();
    });
    for (final String key in DevicesInfo.shellApi.keys) {
      if (!Config.devicesMap.containsKey(widget.devicesEntity.serial)) {
        curProcess = '获取$key信息中...';
        // Log.i(widget.devicesEntity.stat);
        if (mounted) {
          setState(() {});
        }
        if (widget.devicesEntity.isConnect) {
          final String value = await exec(
            'adb -s ${widget.devicesEntity.serial} shell getprop ${DevicesInfo.shellApi[key]}',
          );
          Log.i('value->$value');
          if (value.isNotEmpty && value.length <= 10)
            Config.devicesMap[widget.devicesEntity.serial] = value;
        }
      }
      progress++;
      if (progress == progressMax) {
        curProcess = null;
        if (mounted) {
          setState(() {});
        }
        int time = 0;
        while (time < 3) {
          if (!mounted) {
            break;
          }
          await animationController?.forward();
          await Future<void>.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            await animationController?.reverse();
          }
          time++;
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
        milliseconds: 300,
      ),
    );
    progressAnimaCTL = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 600,
      ),
    );
    shadow = Tween<double>(begin: 0, end: 1).animate(animationController);
    shadow.addListener(() {
      if (mounted) {
        setState(() {});
      }
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
      onTap: () {},
      child: Container(
        height: 54,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 4.w,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.accent,
                          ),
                          height: Dimens.gap_dp6,
                          width: Dimens.gap_dp6,
                        ),
                        SizedBox(
                          width: Dimens.gap_dp10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _title,
                              style: const TextStyle(
                                height: 1.2,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: CandyColors.orange,
                                borderRadius: BorderRadius.circular(6.w)
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 4.w,vertical: 2.w),
                              child: Text(
                                curProcess ?? widget.devicesEntity.stat,
                                style:  TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (isAddress(widget.devicesEntity.serial))
                          IconButton(
                            tooltip: '断开连接',
                            icon: const Icon(Icons.clear),
                            onPressed: () async {
                              AdbUtil.stopPoolingListDevices();
                              await AdbUtil.disconnectDevices(
                                widget.devicesEntity.serial,
                              );
                              AdbUtil.startPoolingListDevices();
                              // Global.instance.pseudoTerminal.write(
                              //   'adb disconnect ${widget.devicesEntity.serial}\n',
                              // );
                            },
                          ),
                        if (!widget.devicesEntity.isConnect)
                          IconButton(
                            tooltip: '重新连接',
                            icon: const Icon(Icons.refresh),
                            onPressed: () async {
                              Log.e(widget.devicesEntity.serial);
                              AdbUtil.reconnectDevices(
                                widget.devicesEntity.serial,
                              );
                            },
                          ),
                        IconButton(
                          icon: const Icon(
                            Icons.app_registration,
                            size: 18,
                            color: Colors.black87,
                          ),
                          onPressed: () async {
                            if (!widget.devicesEntity.isConnect) {
                              showToast('设备未正常连接');
                              return;
                            }
                            await DexServer.startServer(
                              widget.devicesEntity.serial,
                            );
                            Get.toNamed(
                              AppManagerRoutes.home,
                              arguments: YanProcess()
                                ..exec(
                                    'adb -s ${widget.devicesEntity.serial} shell'),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Colors.black87,
                          ),
                          onPressed: () async {
                            if (!widget.devicesEntity.isConnect) {
                              showToast('设备未正常连接');
                              return;
                            }
                            Navigator.of(
                              context,
                            ).push<void>(
                              MaterialPageRoute(
                                builder: (_) {
                                  return DeveloperTool(
                                    serial: widget.devicesEntity.serial,
                                  );
                                },
                              ),
                            );
                          },
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
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).primaryColor,
                      ),
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.15),
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
