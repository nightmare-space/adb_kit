import 'dart:io';

import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/config/envirpath.dart';
import 'package:adb_tool/utils/custom_process.dart';
import 'package:flutter/material.dart';

class DevicesItem extends StatefulWidget {
  const DevicesItem({Key key, this.serial}) : super(key: key);
  // 可能是ip地址可能是设备编号
  final String serial;

  @override
  _DevicesItemState createState() => _DevicesItemState();
}

class _DevicesItemState extends State<DevicesItem>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Color proColor = Colors.blue;
  Animation<double> shadow;
  double progress = 0;
  DevicesInfo devicesInfo = DevicesInfo();
  // 当前在干嘛
  String curProcess = '';

  final List<bool> _list = <bool>[];
  Future<void> getDeviceInfo() async {
    // print('object');
    // currentIp = ip.replaceAll(RegExp('\\s.*'), '');
    curProcess = 'push jar中...';
    setState(() {});
    await NiProcess.exec(
      'adb -s ${widget.serial} push /data/data/com.example.scrcpy_client/files/scrcpy-server.jar /data/local/tmp',
    );
    progress++;
    curProcess = 'push jar中...';
    setState(() {});
    curProcess = '反向监听端口中...';
    setState(() {});
    ProcessResult result = await Process.run(
      'sh',
      [
        '-c',
        'export PATH=/data/data/com.example.scrcpy_client/files:\$PATH\n adb -s ${widget.serial} forward tcp:1234 localabstract:scrcpy\n'
      ],
      runInShell: false,
      includeParentEnvironment: true,
    );
    print('result.stdout==>${result.stdout}');
    print('result.stderr==>${result.stderr}');
    // return;
    progress++;
    for (final String key in DevicesInfo.shellApi.keys) {
      curProcess = '获取$key信息中...';
      setState(() {});
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        NiProcess.exit();
      });
      final String value = await NiProcess.exec(
          'adb -s ${widget.serial} shell getprop ${DevicesInfo.shellApi[key]}\n');
      devicesInfo.setValue(key, value);
      progress++;
      if (progress == 8) {
        await animationController.forward();
        await animationController.reverse();
        proColor = Colors.green;
        curProcess = '完成';
        setState(() {});
      }
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
    print(_list);
  }

  @override
  void initState() {
    super.initState();
    getDeviceInfo();
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
    // animationController.forward();
  }

  Future<void> getDevicesMsg() {}
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final String function = '''
                function adbRemote(){
                  su -c '
                  echo  -e "\\033[1;34m推送投屏jar...\n\\033[0m"
                  ${EnvirPath.binPath}/adb -s ${widget.serial} push ${EnvirPath.binPath}/scrcpy-server.jar /data/local/tmp
                  echo  -e "\\033[1;34m监听端口\\033[0m"
                  ${EnvirPath.binPath}/adb -s ${widget.serial} forward tcp:1234 localabstract:scrcpy
                  echo  -e "\\033[1;34m启动投屏\\033[0m"
                  ${EnvirPath.binPath}/adb -s ${widget.serial} shell 'CLASSPATH=/data/local/tmp/scrcpy-server.jar app_process / com.genymobile.scrcpy.Server 1.12.1 0 8000000 0 true - false true'
                  sleep 0.5
                  '
                }
                ''';
        // Process.run('scrcpy', ['-s', '${widget.serial}']);
        NiProcess.exec(
            "adb -s ${widget.serial} shell 'CLASSPATH=/data/local/tmp/scrcpy-server.jar app_process / com.genymobile.scrcpy.Server 1.12.1 0 8000000 0 true - false true'");
        // final NitermController controller = NitermController();
        // await controller.defineTermFunc(function);
        // controller.exec('adbRemote');
        // // TermUtils.openTerm(
        // //   context: context,
        // //   controller: controller,
        // //   exec: 'adbRemote',
        // // );
        await Future<void>.delayed(
          const Duration(seconds: 2),
        );
      },
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
                          height: Dimens.gap_dp24,
                          width: Dimens.gap_dp8,
                          color: Colors.purple,
                        ),
                        SizedBox(
                          width: Dimens.gap_dp4,
                        ),
                        Text(
                          widget.serial,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '$curProcess',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(Dimens.gap_dp24),
                          onTap: () {
                            print(devicesInfo.devicesInfo);
                            showDialog<void>(
                              context: context,
                              child: DevicesInfoDialog(
                                devicesInfo: devicesInfo,
                              ),
                            );
                          },
                          child: SizedBox(
                            width: Dimens.gap_dp48,
                            height: Dimens.gap_dp48,
                            child: Icon(
                              Icons.check_circle_outline,
                            ),
                          ),
                        ),
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
                      value: progress / 8,
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
  String get abi => devicesInfo['架构'];
  // 芯片
  String get hardware => devicesInfo['芯片'];
  // Android版本
  String get version => devicesInfo['Android版本'];
  // 品牌
  String get manufacturer => devicesInfo['品牌'];
  // 设备代号
  String get device => devicesInfo['设备代号'];
  // 型号
  String get model => devicesInfo['型号'];
  Map<String, String> devicesInfo = {};
  static Map<String, String> shellApi = <String, String>{
    '架构': 'ro.product.cpu.abi',
    '芯片': 'ro.boot.hardware',
    'Android版本': 'ro.build.version.release',
    '品牌': 'ro.product.manufacturer',
    '设备代号': 'ro.product.device',
    '型号': 'ro.product.model',
  };
  List<String> deviceStat = <String>[
    'show_touches',
    'pointer_location',
  ];
  void setValue(String key, String value) {
    devicesInfo[key] = value;
  }

  String getValue(
    String key,
  ) {
    if (devicesInfo.containsKey(key)) {
      return devicesInfo[key];
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
            padding: EdgeInsets.symmetric(
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
