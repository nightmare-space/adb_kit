import 'package:adb_kit/app/modules/history/history_page.dart';
import 'package:adb_kit/app/modules/home/views/tablet_home.dart';
import 'package:adb_kit/app/modules/log_page.dart';
import 'package:adb_kit/app/modules/net_debug/remote_debug_page.dart';
import 'package:adb_kit/app/modules/overview/pages/overview_page.dart';
import 'package:adb_kit/app/modules/setting/setting_page.dart';
import 'package:adb_kit/app/modules/terminal_page/exec_cmd_page.dart';
import 'package:adb_kit/config/config.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

Map<String, Widget> _routes = {};

String license = '''
BSD 3-Clause License

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
   this software without specific prior written permission.
''';

Widget? drawerPages(String route) {
  if (_routes.isNotEmpty) {
    return _routes[route];
  }
  _routes = {};
  _routes[DrawerRoutes.home] = const OverviewPage();
  _routes[DrawerRoutes.history] = const HistoryPage(showLeading: true);
  // _routes[DrawerRoutes.networkDebug] = const RemoteDebugPage();
  _routes[DrawerRoutes.terminal] = const ExecCmdPage();
  _routes[DrawerRoutes.log] = const LogPage();
  _routes[DrawerRoutes.setting] = const SettingsPage();
  _routes[DrawerRoutes.about] = AboutPage(
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
    license: license.trim(),
  );
  return _routes[route];
}

class NiDrawer extends StatefulWidget {
  const NiDrawer({
    super.key,
    required this.items,
    this.onChanged,
    this.expanded = false,
    this.width,
  });
  final List<NiDrawerItem> items;
  final void Function(String value)? onChanged;
  final bool expanded;
  final double? width;

  NiDrawer copyWith({
    List<NiDrawerItem>? items,
    void Function(String value)? onChanged,
    bool? expanded,
    double? width,
  }) {
    return NiDrawer(
      items: items ?? this.items,
      onChanged: onChanged ?? this.onChanged,
      expanded: expanded ?? this.expanded,
      width: width ?? this.width,
    );
  }

  @override
  State<NiDrawer> createState() => _NiDrawerState();
}

class _NiDrawerState extends State<NiDrawer> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeAreaFix(
        child: SizedBox(
          width: widget.width,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w),
            child: Column(
              children: [
                for (NiDrawerItem item in widget.items)
                  SizedBox(
                    child: InkWell(
                      onTap: () {
                        widget.onChanged?.call(item.value.toString());
                      },
                      borderRadius: BorderRadius.circular(12.w),
                      child: item.copyWith(
                        expanded: widget.expanded,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NiDrawerItem<T> extends StatefulWidget {
  const NiDrawerItem({
    super.key,
    required this.value,
    required this.groupValue,
    required this.mini,
    required this.title,
    this.tooltip,
    this.expanded = false,
  });
  final T value;
  final T groupValue;
  final String? tooltip;
  final Widget mini;
  final Widget title;
  final bool expanded;

  NiDrawerItem copyWith({
    T? value,
    T? groupValue,
    String? tooltip,
    Widget? mini,
    Widget? title,
    bool? expanded,
  }) {
    return NiDrawerItem(
      value: value ?? this.value,
      groupValue: groupValue ?? this.groupValue,
      tooltip: tooltip ?? this.tooltip,
      mini: mini ?? this.mini,
      title: title ?? this.title,
      expanded: expanded ?? this.expanded,
    );
  }

  @override
  State<NiDrawerItem<T>> createState() => _NiDrawerItemState<T>();
}

class _NiDrawerItemState<T> extends State<NiDrawerItem<T>> {
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isChecked = widget.value == widget.groupValue;
    if (widget.expanded) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 48.w,
            decoration: isChecked
                ? BoxDecoration(
                    color: colorScheme.primary.withAlpha(opacity01),
                    borderRadius: BorderRadius.circular(8.w),
                  )
                : null,
          ),
          SizedBox(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 16.w),
                child: Row(
                  children: [
                    IconTheme(
                      data: IconThemeData(
                        size: 18.w,
                        color: isChecked ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                      ),
                      child: widget.mini,
                    ),
                    SizedBox(width: 8.w),
                    DefaultTextStyle(
                      style: TextStyle(
                        color: isChecked ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                        fontSize: 14.w,
                        fontWeight: FontWeight.bold,
                      ),
                      child: widget.title,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Tooltip(
      message: widget.tooltip ?? '',
      child: Container(
        height: 54.w,
        width: 54.w,
        decoration: isChecked
            ? BoxDecoration(
                color: colorScheme.primary.withAlpha(opacity015),
                borderRadius: BorderRadius.circular(12.w),
              )
            : null,
        child: DefaultTextStyle(
          style: TextStyle(
            color: isChecked ? colorScheme.primary : colorScheme.onSurface,
            fontSize: 12.w,
            fontWeight: FontWeight.bold,
          ),
          child: widget.mini,
        ),
      ),
    );
  }
}
