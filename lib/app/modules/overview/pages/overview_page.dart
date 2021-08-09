import 'dart:io';

import 'package:adb_tool/app/modules/connect/connect_page.dart';
import 'package:adb_tool/app/modules/online_devices/views/online_view.dart';
import 'package:adb_tool/app/modules/overview/list/devices_list.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/pages/terminal.dart';
import 'package:adb_tool/global/widget/custom_icon_button.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adb_tool/utils/scan_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';

import '../../dialog/connect_remote.dart';

class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Log.d('回调 ${Responsive.of(context).screenType}');
    AppBar appBar;
    if (kIsWeb || Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        brightness: Brightness.light,
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
          if (GetPlatform.isAndroid)
            NiIconButton(
              child: SvgPicture.asset(
                GlobalAssets.qrCode,
                color: Colors.black,
              ),
              onTap: () async {
                ScanUtil.parseScan();
              },
            ),
          SizedBox(width: Dimens.gap_dp12),
        ],
      );
    }
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
      appBar: appBar,
      body: buildBody(context),
    );
  }

  Padding buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // MacosContextMenuItem(
            //   content: Text('data'),
            // ),
            Row(
              children: [
                ItemHeader(color: CandyColors.candyPink),
                Text(
                  '已成功连接的设备',
                  style: TextStyle(
                    fontSize: Dimens.font_sp16,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
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
                ItemHeader(color: CandyColors.candyBlue),
                Text(
                  '快捷命令',
                  style: TextStyle(
                    fontSize: Dimens.font_sp16,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
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
                    const String cmd = 'adb start-server\r';
                    Global.instance.pseudoTerminal.write(cmd);
                  },
                ),
                ItemButton(
                  title: '停止服务',
                  onTap: () async {
                    const String cmd = 'adb kill-server\r';
                    Global.instance.pseudoTerminal.write(cmd);
                  },
                ),
                ItemButton(
                  title: '重启服务',
                  onTap: () async {
                    const String cmd = 'adb kill-server && adb start-server\r';
                    Global.instance.pseudoTerminal.write(cmd);
                  },
                ),
                ItemButton(
                  title: '连接远程设备',
                  onTap: () async {
                    final String cmd = await showCustomDialog<String>(
                      context: context,
                      child: Theme(
                        data: Theme.of(context),
                        child: ConnectRemote(),
                      ),
                    );
                    if (cmd == null) {
                      return;
                    }
                    Global.instance.pseudoTerminal.write(cmd);
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
                ItemButton(
                  title: '复制ADB KEY',
                  onTap: () async {
                    String homePath = '';
                    if (Platform.isMacOS) {
                      homePath = Platform.environment['HOME'];
                    } else if (Platform.isAndroid) {
                      homePath = RuntimeEnvir.binPath;
                    }
                    final File adbKey = File(
                      '$homePath/.android/adbkey.pub',
                    );
                    if (adbKey.existsSync()) {
                      await Clipboard.setData(
                        ClipboardData(
                          text: adbKey.readAsStringSync(),
                        ),
                      );
                      showToast('已复制');
                    } else {
                      showToast('未发现adb key');
                    }
                  },
                ),
              ],
            ),
            Row(
              children: [
                const ItemHeader(color: CandyColors.candyPurpleAccent),
                Text(
                  '运行ADB TOOL的设备',
                  style: TextStyle(
                    fontSize: Dimens.font_sp16,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: Dimens.gap_dp8,
            ),
            OnlineView(),
            Row(
              children: [
                const ItemHeader(color: CandyColors.candyCyan),
                Text(
                  '终端',
                  style: TextStyle(
                    fontSize: Dimens.font_sp16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: Dimens.gap_dp16,
            ),
            const SizedBox(
              height: 200,
              child: TerminalPage(),
            ),
            // ProcessPage(
            //   height: 100,
            // ),
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
    return NiCardButton(
      borderRadius: Dimens.gap_dp8,
      shadowColor: Colors.black,
      blurRadius: Dimens.gap_dp4,
      spreadRadius: 0,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.gap_dp16,
          vertical: Dimens.gap_dp8,
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
