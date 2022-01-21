import 'dart:convert';

import 'package:adb_tool/app/model/adb_historys.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';

class ConfigController extends GetxController {
  ConfigController() {}
  Color primaryColor = AppColors.accent;
  bool autoConnect = true;

  static Locale english = const Locale('en');
  static Locale chinese = const Locale('zh', 'CN');
  YanTheme theme = LightTheme();
  bool get isDarkTheme => theme is DarkTheme;
  Locale locale = chinese;
  ScreenType screenType;

  void changeScreenType(ScreenType screenType) {
    this.screenType = screenType;
    Get.forceAppUpdate();
  }

  void changeLocal(Locale locale) {
    this.locale = locale;
    update();
    Get.updateLocale(locale);
  }

  void changeTheme(YanTheme theme) {
    this.theme = theme;
    Get.forceAppUpdate();
  }

  void changeAutoConnectState(bool value) {
    autoConnect = value;
    update();
  }

  bool showPerformanceOverlay = false;
  void showPerformanceOverlayChange(bool value) {
    showPerformanceOverlay = value;
    update();
  }

  bool showSemanticsDebugger = false;
  void showSemanticsDebuggerChange(bool value) {
    showSemanticsDebugger = value;
    update();
  }

  bool debugShowMaterialGrid = false;
  void debugShowMaterialGridChange(bool value) {
    debugShowMaterialGrid = value;
    update();
  }

  bool checkerboardRasterCacheImages = false;
  void checkerboardRasterCacheImagesChange(bool value) {
    checkerboardRasterCacheImages = value;
    update();
  }
}
