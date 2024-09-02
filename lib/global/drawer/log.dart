import 'package:adb_kit/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_kit/app/modules/drawer/tablet_drawer.dart';
import 'package:adb_kit/app/modules/log_page.dart';
import 'package:adb_kit/core/interface/adb_page.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:flutter/material.dart';

class LogDrawer extends ADBPage {
  @override
  Widget buildDrawer(BuildContext context) {
    return DrawerItem(
      value: runtimeType.toString(),
      groupValue: Global().drawerRoute,
      title: S.of(context).log,
      iconData: Icons.pending_outlined,
    );
  }

  @override
  Widget buildTabletDrawer(BuildContext context) {
    return TabletDrawerItem(
      value: runtimeType.toString(),
      groupValue: Global().drawerRoute,
      title: S.of(context).log,
      iconData: Icons.pending_outlined,
    );
  }

  @override
  bool get isActive => true;

  @override
  Widget buildPage(BuildContext context) {
    return const LogPage();
  }

  @override
  void onTap() {}
}
