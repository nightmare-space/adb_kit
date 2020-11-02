// 安装 adb 工具到系统
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/global/provider/process_info.dart';
import 'package:adb_tool/utils/custom_process.dart';
import 'package:adb_tool/utils/platform_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'home_page.dart';
import 'process_page.dart';
import 'toolkit_colors.dart';

class AdbInstallToSystemPage extends StatefulWidget {
  @override
  _AdbInstallToSystemPageState createState() => _AdbInstallToSystemPageState();
}

class _AdbInstallToSystemPageState extends State<AdbInstallToSystemPage> {
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.gap_dp8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: const <Widget>[
                    ItemHeader(
                      color: YanToolColors.accentColor,
                    ),
                    Text(
                      '安装到系统(需要root)',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.center,
                  child: Text(
                    '请选择安装路径',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            binPath,
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Radio(
                            value: binPath,
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
                              fontWeight: FontWeight.bold,
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
                ),
                Text(
                  'tips:建议选择 /system/xbin ,因为安卓自带程序大部分都在 system/bin ,装在前者更方便管理个人安装的一些可执行程序。',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: Dimens.font_sp12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        120,
                  ),
                  // height: MediaQuery.of(context).size.height * 3 / 4,
                  child: const ProcessPage(),
                ),
              ],
            ),
          ),
          Align(
            alignment: const Alignment(0, 0.5),
            child: SizedBox(
              height: Dimens.gap_dp52,
              child: ItemButton(
                title: '安装',
                onTap: () async {
                  NiProcess.exec('su');
                  Provider.of<ProcessState>(context).clear();
                  final List<String> cmds = [
                    'cp ${PlatformUtil.getFilsePath(Config.packageName)}/adb $choosePath/adb',
                    'cp ${PlatformUtil.getFilsePath(Config.packageName)}/adb.bin $choosePath/adb.bin',
                  ];
                  String execCmd = 'mount -o rw,remount /\n';
                  for (final String cmd in cmds) {
                    execCmd += 'echo $cmd\n$cmd\n';
                  }
                  print(execCmd);
                  NiProcess.exec(
                    execCmd,
                    getStderr: true,
                    callback: (s) {
                      print('ss======>$s');
                      if (s.trim() == 'exitCode') {
                        return;
                      }
                      Provider.of<ProcessState>(context).appendOut(s);
                    },
                  );
                  // String result = '';
                  // for (final String cmd in cmds) {
                  //   result += await exec('echo $cmd\n$cmd');
                  //   Provider.of<ProcessState>(context).appendOut(result);
                  // }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
