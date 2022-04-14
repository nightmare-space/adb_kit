import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/app/routes/app_pages.dart';
import 'package:adb_tool/core/interface/adb_page.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/material.dart';

class Home extends ADBPage {
  @override
  Widget buildDrawer(BuildContext context) {
    return DrawerItem(
      title: S.of(context).home,
      value: Routes.overview,
      groupValue: Global().drawerRoute,
      onTap: (index) {
        // widget.onChanged?.call(index);
      },
      iconData: Icons.home,
    );
  }

  @override
  bool isActive;

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
