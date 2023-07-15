import 'dart:io';

import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/app/modules/overview/pages/overview_page.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:adb_kit/global/widget/xterm_wrapper.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'src/platform_menu.dart';
import 'suggestion.dart';
import 'termare_view_with_bar.dart';

class ExecCmdPage extends StatefulWidget {
  const ExecCmdPage({Key? key}) : super(key: key);

  @override
  State createState() => _ExecCmdPageState();
}

class _ExecCmdPageState extends State<ExecCmdPage> {
  final ConfigController controller = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBar? appBar;
    if (ResponsiveBreakpoints.of(context).isMobile || controller.screenType == ScreenType.phone) {
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
        left: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: 8.w,
            horizontal: 8.w,
          ),
          child: CardItem(
            child: Column(
              children: [
                Expanded(
                  child: Builder(builder: (context) {
                    if (GetPlatform.isDesktop) {
                      return AppPlatformMenu(
                          child: Home(
                        pty: Global().pty!,
                      ));
                    }
                    XTermWrapper;
                    return TermareViewWithBottomBar(
                      pty: Global().pty!,
                      terminal: Global().terminal,
                      child: AppPlatformMenu(
                          child: Home(
                        pty: Global().pty!,
                      )),
                      // child: XTermWrapper(
                      //   pseudoTerminal: Global().pty,
                      //   terminal: Global().terminal,
                      // ),
                    );
                  }),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      ItemButton(
                        title: '开启服务',
                        onTap: () async {
                          String cmd = '$adb start-server\r';
                          Global().pty!.writeString(cmd);
                          AdbUtil.startPoolingListDevices();
                        },
                      ),
                      ItemButton(
                        title: '停止服务',
                        onTap: () async {
                          String cmd = '$adb kill-server\r';
                          Global().pty!.writeString(cmd);
                          AdbUtil.stopPoolingListDevices();
                          final DevicesController controller = Get.find();
                          controller.clearDevices();
                        },
                      ),
                      ItemButton(
                        title: '重启服务',
                        onTap: () async {
                          String cmd = '$adb kill-server && $adb start-server\r';
                          Global().pty!.writeString(cmd);
                        },
                      ),
                      ItemButton(
                        title: '复制ADB KEY',
                        onTap: () async {
                          String? homePath = '';
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
  const ItemButton({Key? key, this.title, this.onTap}) : super(key: key);
  final String? title;
  final void Function()? onTap;

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
          color: Theme.of(context).colorScheme.background,
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
                title!,
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
