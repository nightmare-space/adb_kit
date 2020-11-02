import 'dart:io';

import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/global/material_cliprrect.dart';
import 'package:adb_tool/global/provider/process_info.dart';
import 'package:adb_tool/global/widget/fullheight_listview.dart';
import 'package:adb_tool/utils/platform_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dialog/connect_remote.dart';
import 'list/devices_list.dart';
import 'process_page.dart';
import 'toolkit_colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ),
      child: SingleChildScrollView(
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
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: Dimens.gap_dp8,
              ),
              child: DevicesList(),
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
            Wrap(
              spacing: 0,
              alignment: WrapAlignment.start,
              runAlignment: WrapAlignment.start,
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                ItemButton(
                  title: '开启服务',
                  onTap: () async {
                    Provider.of<ProcessState>(context).clear();
                    const String cmd = 'adb start-server';
                    final String result = await exec('echo $cmd\n$cmd');
                    Provider.of<ProcessState>(context).appendOut(result);
                  },
                ),
                SizedBox(
                  width: Dimens.setWidth(108),
                  child: ItemButton(
                    title: '停止服务',
                    onTap: () async {
                      Provider.of<ProcessState>(context).clear();
                      const String cmd = 'adb kill-server';
                      final String result = await exec('echo $cmd\n$cmd');
                      Provider.of<ProcessState>(context).appendOut(result);
                    },
                  ),
                ),
                ItemButton(
                  title: '重启服务',
                  onTap: () async {
                    Provider.of<ProcessState>(context).clear();
                    const String cmd = 'adb kill-server\nadb start-server';
                    final String result = await exec('echo $cmd\n$cmd\n');
                    Provider.of<ProcessState>(context).appendOut(result);
                  },
                ),
                ItemButton(
                  title: '连接远程设备',
                  onTap: () async {
                    final String cmd = await showDialog<String>(
                      context: context,
                      child: ConnectRemote(),
                    );
                    if (cmd == null) {
                      return;
                    }
                    Provider.of<ProcessState>(context).clear();
                    final String result = await exec('echo $cmd\n$cmd');
                    Provider.of<ProcessState>(context).appendOut(result);
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
                  '安卓端命令(为本机执行的命令)',
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
                  title: '打开远程调试',
                  onTap: () async {
                    Provider.of<ProcessState>(context).clear();
                    final ProcessResult result = await Process.run(
                      'sh',
                      [
                        '-c',
                        '''
                        adb -s ${Config.curDevicesSerial} tcpip 5555
                        '''
                      ],
                    );
                    String value = result.stdout.toString().trim();
                    value += result.stderr.toString().trim();
                    print(value);
                    Provider.of<ProcessState>(context).appendOut(value);
                    // NiProcess.exec(
                    //   'adb tcpip 5555',
                    //   getStderr: true,
                    //   callback: (s) {
                    //     print('ss======>$s');
                    //     if (s.trim() == 'exitCode') {
                    //       return;
                    //     }
                    //     Provider.of<ProcessState>(context).appendOut(s);
                    //   },
                    // );
                  },
                ),
                const ItemButton(
                  title: '关闭远程调试',
                ),
              ],
            ),
            const FullHeightListView(
              child: ProcessPage(
                height: 100,
              ),
            ),
          ],
        ),
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
      child: Container(
        width: title.length * 14.0 + 32,
        decoration: const BoxDecoration(color: Colors.white),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
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
