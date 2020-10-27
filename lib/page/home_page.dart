import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/global/material_cliprrect.dart';
import 'package:adb_tool/global/provider/process_state.dart';
import 'package:adb_tool/utils/custom_process.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'list/devices_list.dart';
import 'process_page.dart';
import 'toolkit_colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String binPath = '/system/bin';
  String xbinPath = '/system/xbin';
  String choosePath;

  @override
  void initState() {
    super.initState();
    choosePath = binPath;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      allowFontScaling: false,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ),
      child: Column(
        children: [
          Row(
            children: [
              ItemHeader(
                color: YanToolColors.candyColor[0],
              ),
              const Text(
                '已成功连接的设备',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          DevicesList(),

          // FlatButton(
          //   onPressed: () {},
          //   child: Text('开启服务'),
          // ),
          // FlatButton(
          //   onPressed: null,
          //   child: Text('重启 adb server'),
          // ),
          // FlatButton(
          //   onPressed: null,
          //   child: Text('打开 ADB 远程调试'),
          // ),
          // FlatButton(
          //   onPressed: null,
          //   child: Text('关闭 ADB 远程调试'),
          // ),
          // const FlatButton(
          //   onPressed: null,
          //   child: Text('向设备安装apk'),
          // ),
          Row(
            children: [
              const ItemHeader(
                color: YanToolColors.accentColor,
              ),
              const Text(
                '安装到系统(需要root)',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                '/system/bin',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              Radio(
                value: '/system/bin',
                groupValue: choosePath,
                onChanged: (String value) {
                  choosePath = value;
                  setState(() {});
                },
              ),
            ],
          ),
          Row(
            children: [
              Text(
                xbinPath,
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              Radio(
                value: xbinPath,
                groupValue: choosePath,
                onChanged: (String value) {
                  choosePath = value;
                  setState(() {});
                },
              ),
            ],
          ),
          Row(
            children: [
              ItemHeader(
                color: YanToolColors.candyColor[1],
              ),
              const Text(
                '快捷命令',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              ItemButton(
                title: '开启服务',
                onTap: () {
                  Provider.of<ProcessState>(context).clear();
                  NiProcess.exec('adb server', getStderr: true, callback: (s) {
                    print('ss======>$s');
                    if (s.trim() == 'exitCode') {
                      return;
                    }
                    Provider.of<ProcessState>(context).appendOut(s);
                  });
                },
              ),
              const ItemButton(
                title: '停止服务',
              ),
              const ItemButton(
                title: '重启服务',
              ),
            ],
          ),
          ProcessPage(),
        ],
      ),
    );
  }
}

class ItemButton extends StatelessWidget {
  const ItemButton({Key key, this.title, this.onTap}) : super(key: key);
  final String title;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return MaterialClipRRect(
      onTap: onTap,
      child: Center(
        child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ItemHeader extends StatelessWidget {
  const ItemHeader({Key key, this.color}) : super(key: key);
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        right: Dimens.gap_dp6,
      ),
      color: color,
      width: 6,
      height: 32,
    );
  }
}
