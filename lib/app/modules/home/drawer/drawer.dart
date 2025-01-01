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

List<DrawerItem> desktopPhoneDrawer(String route) {
  return [
    DrawerItem(
      title: S.current.home,
      value: S.current.home,
      iconData: Icons.home,
      groupValue: route,
    ),
    DrawerItem(
      title: S.current.historyConnect,
      value: S.current.historyConnect,
      iconData: Icons.history,
      groupValue: route,
    ),
    DrawerItem(
      title: S.current.networkDebug,
      value: S.current.networkDebug,
      iconData: Icons.signal_wifi_4_bar,
      groupValue: route,
    ),
    DrawerItem(
      title: S.current.terminal,
      value: S.current.terminal,
      iconData: Icons.code,
      groupValue: route,
    ),
    DrawerItem(
      title: S.current.log,
      value: S.current.log,
      iconData: Icons.pending_outlined,
      groupValue: route,
    ),
    // const SettingsPage();
    DrawerItem(
      title: S.current.setting,
      value: S.current.setting,
      iconData: Icons.settings,
      groupValue: route,
    ),
    DrawerItem(
      title: S.current.about,
      value: S.current.about,
      iconData: Icons.info_outline,
      groupValue: route,
    ),
  ];
}

List<TabletDrawerItem> tabletDrawer(String route) {
  return [
    TabletDrawerItem(
      title: S.current.home,
      value: S.current.home,
      groupValue: route,
      iconData: Icons.home,
    ),
    TabletDrawerItem(
      title: S.current.historyConnect,
      value: S.current.historyConnect,
      groupValue: route,
      iconData: Icons.history,
    ),
    TabletDrawerItem(
      title: S.current.networkDebug,
      value: S.current.networkDebug,
      groupValue: route,
      iconData: Icons.signal_wifi_4_bar,
    ),
    TabletDrawerItem(
      title: S.current.terminal,
      value: S.current.terminal,
      groupValue: route,
      iconData: Icons.code,
    ),
    TabletDrawerItem(
      title: S.current.log,
      value: S.current.log,
      groupValue: route,
      iconData: Icons.pending_outlined,
    ),
    TabletDrawerItem(
      title: S.current.setting,
      value: S.current.setting,
      groupValue: route,
      iconData: Icons.settings,
    ),
    TabletDrawerItem(
      title: S.current.about,
      value: S.current.about,
      groupValue: route,
      iconData: Icons.info_outline,
    ),
  ];
}

Map<String, Widget> _routes = {};

Widget? drawerPages(String route) {
  if (_routes.isNotEmpty) {
    return _routes[route];
  }
  _routes = {};
  _routes[S.current.home] = const OverviewPage();
  _routes[S.current.historyConnect] = const HistoryPage(showLeading: true);
  _routes[S.current.networkDebug] = const RemoteDebugPage();
  _routes[S.current.terminal] = const ExecCmdPage();
  _routes[S.current.log] = const LogPage();
  _routes[S.current.setting] = const SettingsPage();
  _routes[S.current.about] = AboutPage(
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
  );
  return _routes[route];
}
