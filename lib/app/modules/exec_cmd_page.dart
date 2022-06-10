import 'dart:io';

import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:adb_tool/config/font.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/pages/terminal.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';

class ExecCmdPage extends StatefulWidget {
  const ExecCmdPage({Key key}) : super(key: key);

  @override
  State createState() => _ExecCmdPageState();
}

class _ExecCmdPageState extends State<ExecCmdPage> {
  TextEditingController editingController = TextEditingController();
  final ConfigController controller = Get.find();
  FocusNode focusNode = FocusNode();
  Future<void> execCmd() async {
    Global.instance.pseudoTerminal.write(editingController.text + '\n');
    editingController.clear();
    focusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    Global().initTerminal();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (ResponsiveWrapper.of(context).isPhone ||
        controller.screenType == ScreenType.phone) {
      appBar = AppBar(
        title: Text(S.of(context).terminal),
        automaticallyImplyLeading: false,
        leading: controller.needShowMenuButton
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              )
            : null,
      );
    }
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: Dimens.gap_dp8,
            horizontal: Dimens.gap_dp8,
          ),
          child: CardItem(
            child: Column(
              children: [
                const Expanded(
                  child: TerminalPage(
                    enableInput: true,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      ItemButton(
                        title: '开启服务',
                        onTap: () async {
                          const String cmd = 'adb start-server\r';
                          Global.instance.pseudoTerminal.write(cmd);
                          AdbUtil.startPoolingListDevices();
                        },
                      ),
                      ItemButton(
                        title: '停止服务',
                        onTap: () async {
                          const String cmd = 'adb kill-server\r';
                          Global.instance.pseudoTerminal.write(cmd);
                          AdbUtil.stopPoolingListDevices();
                          final DevicesController controller = Get.find();
                          controller.clearDevices();
                        },
                      ),
                      ItemButton(
                        title: '重启服务',
                        onTap: () async {
                          const String cmd =
                              'adb kill-server && adb start-server\r';
                          Global.instance.pseudoTerminal.write(cmd);
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
                ),
              ],
            ),
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
      borderRadius: Dimens.gap_dp8,
      shadowColor: Colors.black,
      blurRadius: 0,
      spreadRadius: 0,
      onTap: onTap,
      margin: EdgeInsets.all(4.w),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).backgroundColor,
          borderRadius: BorderRadius.circular(10.w),
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 1.w,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 8.w,
        ),
        child: Column(
          children: [
            SizedBox(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
