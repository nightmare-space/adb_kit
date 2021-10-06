import 'package:adb_tool/app/modules/about_page.dart';
import 'package:adb_tool/app/modules/log_page.dart';
import 'package:adb_tool/app/modules/exec_cmd_page.dart';
import 'package:adb_tool/app/modules/history/history_page.dart';
import 'package:adb_tool/app/modules/home/bindings/home_binding.dart';
import 'package:adb_tool/app/modules/home/views/home_view.dart';
import 'package:adb_tool/app/modules/install/adb_insys_page.dart';
import 'package:adb_tool/app/modules/net_debug/remote_debug_page.dart';
import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:adb_tool/app/modules/search_ip_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AdbPages {
  AdbPages._();
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => AdbTool(),
      binding: HomeBinding(),
    ),
  ];
}

Widget getWidget(String route) {
  switch (route) {
    case Routes.about:
      return AboutPage();
      break;
    case Routes.overview:
      return OverviewPage();
      break;
    case Routes.installToSystem:
      return AdbInstallToSystemPage();
      break;
    case Routes.terminal:
      return ExecCmdPage();
      break;
    case Routes.history:
      return HistoryPage();
      break;
    case Routes.searchIp:
      return SearchIpPage();
      break;
    case Routes.netDebug:
      return RemoteDebugPage();
      break;
    case Routes.log:
      return LogPage();
      break;
    default:
    return SizedBox();
  }
}
