// import 'package:adb_kit/app/modules/about/about_page.dart';
import 'package:adb_kit/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_kit/app/modules/drawer/tablet_drawer.dart';
import 'package:adb_kit/config/config.dart';
import 'package:adb_kit/core/interface/adb_page.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class About extends ADBPage {
  @override
  Widget buildDrawer(BuildContext context) {
    return DrawerItem(
      value: runtimeType.toString(),
      groupValue: Global().drawerRoute,
      title: S.of(context).about,
      iconData: Icons.info_outline,
    );
  }

  @override
  Widget buildTabletDrawer(BuildContext context) {
    return TabletDrawerItem(
      value: runtimeType.toString(),
      groupValue: Global().drawerRoute,
      title: S.of(context).about,
      iconData: Icons.info_outline,
    );
  }

  @override
  bool get isActive => true;

  @override
  Widget buildPage(BuildContext context) {
    return AboutPage(
      versionCode: Config.versionCode,
      appVersion: Config.versionName,
      logo: Padding(
        padding: EdgeInsets.only(top: 64.w),
        child: SizedBox(
          width: 100.w,
          height: 100.w,
          child: Image.asset('assets/logo.png'),
        ),
      ),
      openSourceLink: 'https://github.com/nightmare-space/adb_kit',
      otherVersionLink: 'http://nightmare.press/YanTool/resources/ADBTool/?C=N;O=A',
      license: '''BSD 3-Clause License

Copyright (c) 2021,  Nightmare
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this
   list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
   this list of conditions and the following disclaimer in the documentation
   and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
   contributors may be used to endorse or promote products derived from
   this software without specific prior written permission.''',
    );
  }

  @override
  void onTap() {}
}
