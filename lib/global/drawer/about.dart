import 'package:adb_tool/app/modules/about/about_page.dart';
import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/app/routes/app_pages.dart';
import 'package:adb_tool/core/interface/adb_page.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/material.dart';

class About extends ADBPage {
  @override
  Widget buildDrawer(BuildContext context, void Function() onTap) {
    return DrawerItem(
      value: Routes.about,
      groupValue: Global().drawerRoute,
      title: S.of(context).about,
      iconData: Icons.info_outline,
      onTap: (value) async {
        onTap();
      },
    );
  }

  @override
  bool isActive;

  @override
  Widget buildPage(BuildContext context) {
    return AboutPage();
  }

  @override
  void onTap() {
    // TODO: implement onTap
    throw UnimplementedError();
  }
}
