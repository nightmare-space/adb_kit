import 'dart:io';

import 'package:adb_tool/config/candy_colors.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/config/global.dart';
import 'package:adb_tool/global/provider/process_info.dart';
import 'package:adb_tool/global/widget/custom_card.dart';
import 'package:adb_tool/global/widget/custom_icon_button.dart';
import 'package:adb_tool/utils/permission_utils.dart';
import 'package:adb_tool/utils/scan_util.dart';
import 'package:adb_tool/utils/socket_util.dart';
import 'package:adb_tool/utils/udp_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_repository/global_repository.dart';
import 'package:provider/provider.dart';

import 'dialog/connect_remote.dart';
import 'home/provider/device_entitys.dart';
import 'home/qr_scan_page.dart';
import 'list/devices_list.dart';
import 'process_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<DeviceEntity> list = [];
  @override
  void initState() {
    Global.instance.findDevicesCall = (DeviceEntity deviceEntity) {
      if (!list.contains(deviceEntity)) {
        list.add(deviceEntity);
        setState(() {});
      }
      // print('$this deviceEntity->$deviceEntity');
    };
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (Platform.isAndroid) {
      appBar = AppBar(
        brightness: Brightness.light,
        backgroundColor: const Color(0x00f7f7f7),
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(
          '概览',
          style: TextStyle(
            height: 1.0,
            color: Theme.of(context).textTheme.bodyText2.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          NiIconButton(
            child: SvgPicture.asset('assets/icon/QR_code.svg'),
            onTap: () async {
              ScanUtil.parseScan();
            },
          ),
        ],
      );
    }
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        ChangeNotifierProvider<DeviceEntitys>(
          create: (_) => DeviceEntitys(),
        ),
      ],
      child: Builder(
        builder: (_) {
          Global.instance.deviceEntitys = Provider.of(_);
          return Scaffold(
            // floatingActionButton: FloatingActionButton(
            //   onPressed: () async {
            //     RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
            //         .then((RawDatagramSocket socket) async {
            //       socket.broadcastEnabled = true;
            //       // for (int i = 0; i < 255; i++) {
            //       //   socket.send(
            //       //     UniqueKey().toString().codeUnits,
            //       //     InternetAddress('192.168.39.$i'),
            //       //     Config.udpPort,
            //       //   );
            //       // }
            //       UdpUtil.boardcast(socket, UniqueKey().toString());
            //     });
            //   },
            // ),
            appBar: appBar,
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
                            Provider.of<ProcessState>(context)
                                .appendOut(result);
                          },
                        ),
                        ItemButton(
                          title: '停止服务',
                          onTap: () async {
                            Provider.of<ProcessState>(context).clear();
                            const String cmd = 'adb kill-server';
                            final String result = await exec('echo $cmd\n$cmd');
                            Provider.of<ProcessState>(context)
                                .appendOut(result);
                          },
                        ),
                        ItemButton(
                          title: '重启服务',
                          onTap: () async {
                            Provider.of<ProcessState>(context).clear();
                            const String cmd =
                                'adb kill-server\nadb start-server';
                            final String result =
                                await exec('echo $cmd\n$cmd\n');
                            Provider.of<ProcessState>(context)
                                .appendOut(result);
                          },
                        ),
                        ItemButton(
                          title: '连接远程设备',
                          onTap: () async {
                            final String cmd = await showCustomDialog<String>(
                              context: context,
                              child: ConnectRemote(),
                            );
                            if (cmd == null) {
                              return;
                            }
                            Provider.of<ProcessState>(context).clear();
                            final String result = await exec('echo $cmd\n$cmd');
                            Provider.of<ProcessState>(context)
                                .appendOut(result);
                          },
                        ),
                        ItemButton(
                          title: '连接二维码',
                          onTap: () async {
                            await showDialog<String>(
                              context: _,
                              builder: (_) {
                                return QrScanPage();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const ItemHeader(color: CandyColors.candyCyan),
                        const Text(
                          '运行AdbTool的设备',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 48.0 * list.length,
                      child: ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (c, i) {
                          return InkWell(
                            onTap: () async {
                              final NetworkManager socket = NetworkManager(
                                list[i].address,
                                Config.qrPort,
                              );
                              await socket.connect();
                            },
                            child: SizedBox(
                              height: 48.0,
                              child: Row(
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
                                  Center(
                                    child: Row(
                                      children: [
                                        Text(
                                          ' ${list[i].address}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '(${list[i].unique})',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.cast_connected),
                                    onPressed: () async {
                                      final NetworkManager socket =
                                          NetworkManager(
                                        list[i].address,
                                        Config.qrPort,
                                      );
                                      await socket.connect();
                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    ProcessPage(
                      height: 100,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          right: Dimens.gap_dp6,
        ),
        color: color,
        width: Dimens.gap_dp4,
        height: Dimens.gap_dp16,
      ),
    );
  }
}
