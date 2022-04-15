import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/app/modules/drawer/tablet_drawer.dart';
import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:adb_tool/app/routes/app_pages.dart';
import 'package:adb_tool/core/interface/adb_page.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/material.dart';

class Home extends ADBPage {
  @override
  Widget buildDrawer(BuildContext context, void Function() onTap) {
    return DrawerItem(
      title: S.of(context).home,
      value: runtimeType.toString(),
      groupValue: Global().drawerRoute,
      iconData: Icons.home,
      onTap: (value) async {
        onTap();
      },
    );
  }

  @override
  Widget buildTabletDrawer(BuildContext context, void Function() onTap) {
    return TabletDrawerItem(
      title: S.of(context).home,
      value: runtimeType.toString(),
      groupValue: Global().drawerRoute,
      iconData: Icons.home,
      onTap: (value) async {
        onTap();
      },
    );
  }

  @override
  bool get isActive => true;

  @override
  Widget buildPage(BuildContext context) {
    return const OverviewPage();
  }

  @override
  void onTap() {
  }
}
