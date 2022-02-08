import 'dart:convert';

import 'package:adb_tool/app/model/adb_historys.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:settings/src/setting_extension.dart';

class ConfigController extends GetxController {
  ConfigController() {
    initConfig();
  }
  Color primaryColor = AppColors.accent;
  bool autoConnect = true;

  static Locale english = const Locale('en');
  static Locale chinese = const Locale('zh', 'CN');
  YanTheme theme = LightTheme();

  Map<String, YanTheme> themeMap = {
    'light': LightTheme(),
    'dark': DarkTheme(),
  };
  Map<String, Locale> languageMap = {
    'chinese': chinese,
    'english': english,
  };

  bool get isDarkTheme => theme is DarkTheme;
  Locale locale = chinese;
  ScreenType screenType;
  bool get needShowMenuButton =>
      screenType == ScreenType.phone || (screenType == null&&GetPlatform.isAndroid);
  void initConfig() {
    if ('$ScreenType'.get.isNotEmpty) {
      screenType = ScreenType.values.byName('$ScreenType'.get);
    }
    if (themeMap.containsKey('$Theme'.get)) {
      theme = themeMap['$Theme'.get];
    }
    if (languageMap.containsKey('Language'.get)) {
      locale = languageMap['Language'.get];
    }
  }

  void changeScreenType(ScreenType screenType) {
    this.screenType = screenType;
    if (screenType != null) {
      '$ScreenType'.set = screenType.name;
    }
    Get.forceAppUpdate();
  }

  void changeLocal(Locale locale) {
    this.locale = locale;
    if (locale == chinese) {
      'Language'.set = 'chinese';
    } else {
      'Language'.set = 'english';
    }
    update();
    Get.updateLocale(locale);
  }

  void changeTheme(YanTheme theme) {
    this.theme = theme;
    if (isDarkTheme) {
      'Theme'.set = 'dark';
    } else {
      'Theme'.set = 'light';
    }
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
