import 'package:adb_kit/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_kit/app/modules/drawer/tablet_drawer.dart';
import 'package:adb_kit/app/modules/exec_cmd_page.dart';
import 'package:adb_kit/core/interface/adb_page.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:flutter/material.dart';

class Terminal extends ADBPage {
  @override
  Widget buildDrawer(BuildContext context) {
    return DrawerItem(
      value: runtimeType.toString(),
      groupValue: Global().drawerRoute,
      title: S.of(context).terminal,
      iconData: Icons.code,
    );
  }

  @override
  Widget buildTabletDrawer(BuildContext context) {
    return TabletDrawerItem(
      value: runtimeType.toString(),
      groupValue: Global().drawerRoute,
      title: S.of(context).terminal,
      iconData: Icons.code,
    );
  }

  @override
  bool get isActive => true;

  @override
  Widget buildPage(BuildContext context) {
    return const ExecCmdPage();
  }

  @override
  void onTap() {}
}
