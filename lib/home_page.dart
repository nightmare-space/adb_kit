import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      padding: EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ),
      child: Column(
        children: [
          const Text('已成功连接的设备'),
          FlatButton(
            onPressed: () {},
            child: Text('开启服务'),
          ),
          FlatButton(
            onPressed: null,
            child: Text('重启 adb server'),
          ),
          FlatButton(
            onPressed: null,
            child: Text('打开 ADB 远程调试'),
          ),
          FlatButton(
            onPressed: null,
            child: Text('关闭 ADB 远程调试'),
          ),
          const FlatButton(
            onPressed: null,
            child: Text('向设备安装apk'),
          ),
          Row(
            children: [
              Container(
                margin: const EdgeInsets.only(
                  right: 6.0,
                ),
                color: Colors.cyan,
                width: 6,
                height: 32,
              ),
              const Text('安装到系统(需要root)'),
            ],
          ),
          Row(
            children: [
              Text(
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
                style: TextStyle(
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
        ],
      ),
    );
  }
}
