import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/app/routes/app_pages.dart';
import 'package:adb_tool/core/interface/adb_page.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NetDebug extends ADBPage {
  @override
  Widget buildDrawer(BuildContext context) {
    return DrawerItem(
      title: S.of(context).networkDebug,
      value: Routes.netDebug,
      groupValue: Global().drawerRoute,
      iconData: Icons.signal_wifi_4_bar,
      onTap: (index) {
        // widget.onChanged?.call(index);
      },
    );
  }

  @override
  bool get isActive=>GetPlatform.isAndroid;

  @override
  Widget buildPage(BuildContext context) {
    // TODO: implement buildPage
    throw UnimplementedError();
  }

  @override
  void onTap() {
    // TODO: implement onTap
    throw UnimplementedError();
  }
}
