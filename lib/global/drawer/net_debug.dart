import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/app/modules/drawer/tablet_drawer.dart';
import 'package:adb_tool/app/modules/net_debug/remote_debug_page.dart';
import 'package:adb_tool/app/routes/app_pages.dart';
import 'package:adb_tool/core/interface/adb_page.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetDebug extends ADBPage {
  @override
  Widget buildDrawer(BuildContext context, void Function() onTap) {
    return DrawerItem(
      title: S.of(context).networkDebug,
      value: runtimeType.toString(),
      groupValue: Global().drawerRoute,
      iconData: Icons.signal_wifi_4_bar,
      onTap: (value) async {
        onTap();
      },
    );
  }

  @override
  Widget buildTabletDrawer(BuildContext context, void Function() onTap) {
    return TabletDrawerItem(
      title: S.of(context).networkDebug,
      value: runtimeType.toString(),
      groupValue: Global().drawerRoute,
      iconData: Icons.signal_wifi_4_bar,
      onTap: (value) async {
        onTap();
      },
    );
  }

  @override
  bool get isActive => GetPlatform.isAndroid;

  @override
  Widget buildPage(BuildContext context) {
    return const RemoteDebugPage();
  }

  @override
  void onTap() {
  }
}
