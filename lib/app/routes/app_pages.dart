import 'package:adb_tool/app/modules/home/bindings/home_binding.dart';
import 'package:adb_tool/app/modules/home/views/adaptive_view.dart';
import 'package:adb_tool/app/modules/search_ip_page.dart';
import 'package:adb_tool/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AdbPages {
  AdbPages._();
  static const initial = Routes.home;

  static final routes = [
    GetPage(
      name: Routes.home,
      page: () => const ADBToolEntryPoint(),
      binding: HomeBinding(),
    ),
  ];
}

Widget getWidget(String route) {
  switch (route) {
    case Routes.searchIp:
      return const SearchIpPage();
      break;
    default:
    return const SizedBox();
  }
}
