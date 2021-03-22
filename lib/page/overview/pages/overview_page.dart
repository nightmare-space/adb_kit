import 'dart:io';
import 'package:adb_tool/app/modules/online_devices/views/online_view.dart';
import 'package:adb_tool/config/candy_colors.dart';
import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/pages/terminal.dart';
import 'package:adb_tool/global/provider/device_list_state.dart';
import 'package:adb_tool/global/widget/custom_card.dart';
import 'package:adb_tool/global/widget/custom_icon_button.dart';
import 'package:adb_tool/utils/scan_util.dart';
import 'package:adb_tool/utils/socket_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:global_repository/global_repository.dart';
import 'package:provider/provider.dart';
import '../../dialog/connect_remote.dart';
import '../../list/devices_list.dart';
import 'qr_scan_page.dart';

class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  @override
  void initState() {
    Global.instance.deviceListState = DeviceListState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (kIsWeb || Platform.isAndroid) {
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
      providers: [
        ChangeNotifierProvider<DeviceListState>.value(
          value: Global.instance.deviceListState,
        ),
      ],
      child: Builder(
        builder: (_) {
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
            body: buildBody(context, _),
          );
        },
      ),
    );
  }

  Padding buildBody(BuildContext context, BuildContext _) {
    return Padding(
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
                    const String cmd = 'adb start-server\n';
                    Global.instance.pseudoTerminal.write(cmd);
                  },
                ),
                ItemButton(
                  title: '停止服务',
                  onTap: () async {
                    const String cmd = 'adb kill-server\n';
                    Global.instance.pseudoTerminal.write(cmd);
                  },
                ),
                ItemButton(
                  title: '重启服务',
                  onTap: () async {
                    const String cmd = 'adb kill-server && adb start-server\n';
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
                      context: _,
                      builder: (_) {
                        return QrScanPage();
                      },
                    );
                  },
                ),
                ItemButton(
                  title: '复制ADB KEY',
                  onTap: () async {
                    final File adbKey = File(
                      '${PlatformUtil.getBinaryPath()}/.android/adbkey.pub',
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
                const Text(
                  '运行ADB TOOL的设备',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
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
                const Text(
                  '终端',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: Dimens.gap_dp16,
            ),
            SizedBox(
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
      shadowColor: Colors.grey,
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
