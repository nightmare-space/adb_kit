import 'dart:io';

import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/global/material_cliprrect.dart';
import 'package:adb_tool/global/provider/process_info.dart';
import 'package:adb_tool/global/widget/custom_card.dart';
import 'package:adb_tool/utils/permission_utils.dart';
import 'package:adb_tool/utils/socket_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_repository/global_repository.dart';
import 'package:provider/provider.dart';

import 'package:qrscan/qrscan.dart' as scanner;
import 'dialog/connect_remote.dart';
import 'list/devices_list.dart';
import 'process_page.dart';
import 'qr_scan_page.dart';
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
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        backgroundColor: const Color(0x00f7f7f7),
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          'ADB 工具',
          style: TextStyle(
            height: 1.0,
            color: Theme.of(context).textTheme.bodyText2.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset('assets/icon/QR_code.svg'),
            onPressed: () async {
              if (Platform.isAndroid) {
                await PermissionUtil.request();
                final String cameraScanResult = await scanner.scan();
                if (cameraScanResult == null) {
                  return;
                }
                print(
                    'cameraScanResult -> $cameraScanResult ${cameraScanResult.split(':').first} ${cameraScanResult.split(':').last}');
                final ProcessResult result = await Process.run(
                  'ip',
                  ['route'],
                );
                final String deviceIp =
                    result.stdout.toString().trim().replaceAll(
                          RegExp('.* '),
                          '',
                        );
                // 读本机的adb端口一起发送过去
                print('deviceIp -> $deviceIp');
                for (final String serverAddress
                    in cameraScanResult.split(';')) {
                  List<String> serverAddressList = serverAddress.split('.');
                  List<String> localAddressList = deviceIp.split('.');
                  print('serverAddressList->${serverAddressList}');
                  print('localAddressList->${localAddressList}');
                  if (serverAddressList[0] == localAddressList[0] &&
                      serverAddressList[1] == localAddressList[1] &&
                      serverAddressList[2] == localAddressList[2]) {
                    final NetworkManager socket = NetworkManager(
                      serverAddress.split(':').first,
                      int.tryParse(serverAddress.split(':').last),
                    );
                    await socket.init();

                    socket.sendMsg(deviceIp);
                  }
                }
                return;
              }
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ItemHeader(color: CandyColors.candyPink),
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
                  const ItemHeader(color: CandyColors.candyBlue),
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
                  ItemButton(
                    title: '停止服务',
                    onTap: () async {
                      Provider.of<ProcessState>(context).clear();
                      const String cmd = 'adb kill-server';
                      final String result = await exec('echo $cmd\n$cmd');
                      Provider.of<ProcessState>(context).appendOut(result);
                    },
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
                  ItemButton(
                    title: '连接二维码',
                    onTap: () async {
                      await showDialog<String>(
                        context: context,
                        builder: (_) {
                          return QrScanPage();
                        },
                      );
                    },
                  ),
                ],
              ),
              ProcessPage(
                height: 100,
              ),
            ],
          ),
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
    return NiCardButton(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        child: Column(
          children: [
            SizedBox(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
