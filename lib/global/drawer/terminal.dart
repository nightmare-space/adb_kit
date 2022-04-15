import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/app/modules/drawer/tablet_drawer.dart';
import 'package:adb_tool/app/modules/exec_cmd_page.dart';
import 'package:adb_tool/app/routes/app_pages.dart';
import 'package:adb_tool/core/interface/adb_page.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/material.dart';

class Terminal extends ADBPage {
  @override
  Widget buildDrawer(BuildContext context, void Function() onTap) {
    return DrawerItem(
      value: Routes.terminal,
      groupValue: Global().drawerRoute,
      title: S.of(context).terminal,
      iconData: Icons.code,
      onTap: (value) async {
        onTap();
      },
    );
  }

  @override
  Widget buildTabletDrawer(BuildContext context, void Function() onTap) {
    return TabletDrawerItem(
      value: Routes.terminal,
      groupValue: Global().drawerRoute,
      title: S.of(context).terminal,
      iconData: Icons.code,
      onTap: (value) async {
        onTap();
      },
    );
  }

  @override
  bool get isActive => true;

  @override
  Widget buildPage(BuildContext context) {
    return const ExecCmdPage();
  }

  @override
  void onTap() {
  }
}
