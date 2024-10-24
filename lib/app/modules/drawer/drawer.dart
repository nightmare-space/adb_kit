import 'package:adb_kit/app/modules/history/history_page.dart';
import 'package:adb_kit/app/modules/log_page.dart';
import 'package:adb_kit/app/modules/net_debug/remote_debug_page.dart';
import 'package:adb_kit/app/modules/overview/pages/overview_page.dart';
import 'package:adb_kit/app/modules/setting/setting_page.dart';
import 'package:adb_kit/app/modules/terminal_page/exec_cmd_page.dart';
import 'package:adb_kit/config/config.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

import 'drawer_desktop_phone.dart';
import 'drawer_tablet.dart';

String drawerRoute = '';
Widget? page;

List<Widget> desktopPhoneDrawer(BuildContext context) {
  return [
    DrawerItem(
      title: S.of(context).home,
      value: S.of(context).home,
      groupValue: drawerRoute,
      iconData: Icons.home,
    ),
    DrawerItem(
      title: S.of(context).historyConnect,
      value: S.of(context).historyConnect,
      groupValue: drawerRoute,
      iconData: Icons.history,
    ),
    DrawerItem(
      title: S.of(context).networkDebug,
      value: S.of(context).networkDebug,
      groupValue: drawerRoute,
      iconData: Icons.signal_wifi_4_bar,
    ),
    DrawerItem(
      title: S.of(context).terminal,
      value: S.of(context).terminal,
      groupValue: drawerRoute,
      iconData: Icons.code,
    ),
    DrawerItem(
      title: S.of(context).log,
      value: S.of(context).log,
      groupValue: drawerRoute,
      iconData: Icons.pending_outlined,
    ),
    // const SettingsPage();
    DrawerItem(
      title: S.of(context).setting,
      value: S.of(context).setting,
      groupValue: drawerRoute,
      iconData: Icons.settings,
    ),
    DrawerItem(
      title: S.of(context).about,
      value: S.of(context).about,
      groupValue: drawerRoute,
      iconData: Icons.info_outline,
    ),
  ];
}

List<Widget> tabletDrawer(BuildContext context) {
  return [
    TabletDrawerItem(
      title: S.of(context).home,
      value: S.of(context).home,
      groupValue: drawerRoute,
      iconData: Icons.home,
    ),
    TabletDrawerItem(
      title: S.of(context).historyConnect,
      value: S.of(context).historyConnect,
      groupValue: drawerRoute,
      iconData: Icons.history,
    ),
    TabletDrawerItem(
      title: S.of(context).networkDebug,
      value: S.of(context).networkDebug,
      groupValue: drawerRoute,
      iconData: Icons.signal_wifi_4_bar,
    ),
    TabletDrawerItem(
      title: S.of(context).terminal,
      value: S.of(context).terminal,
      groupValue: drawerRoute,
      iconData: Icons.code,
    ),
    TabletDrawerItem(
      title: S.of(context).log,
      value: S.of(context).log,
      groupValue: drawerRoute,
      iconData: Icons.pending_outlined,
    ),
    TabletDrawerItem(
      title: S.of(context).setting,
      value: S.of(context).setting,
      groupValue: drawerRoute,
      iconData: Icons.settings,
    ),
    TabletDrawerItem(
      title: S.of(context).about,
      value: S.of(context).about,
      groupValue: drawerRoute,
      iconData: Icons.info_outline,
    ),
  ];
}

List<Widget> pages(BuildContext context) {
  return [
    const OverviewPage(),
    HistoryPage(),
    RemoteDebugPage(),
    ExecCmdPage(),
    LogPage(),
    SettingsPage(),
    AboutPage(
      versionCode: Config.versionCode,
      appVersion: Config.versionName,
      applicationName: 'ADB KIT',
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
    ),
  ];
}
