import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/app/modules/history/history_page.dart';
import 'package:adb_tool/app/routes/app_pages.dart';
import 'package:adb_tool/core/interface/adb_page.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/material.dart';

class History extends ADBPage {
  @override
  Widget buildDrawer(BuildContext context, void Function() onTap) {
    return DrawerItem(
      title: S.of(context).historyConnect,
      value: Routes.history,
      groupValue: Global().drawerRoute,
      iconData: Icons.history,
      onTap: (value) async {
        Global().changeDrawerRoute(value);
      },
    );
  }

  @override
  bool isActive;

  @override
  Widget buildPage(BuildContext context) {
    return HistoryPage();
  }

  @override
  void onTap() {
    // TODO: implement onTap
    throw UnimplementedError();
  }
}
