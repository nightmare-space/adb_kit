import 'package:adb_tool/config/settings.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:settings/settings.dart';

enum BackgroundStyle {
  image,
  tranparent,
  normal,
}

class ConfigController extends GetxController {
  ConfigController() {
    initConfig();
  }
  BackgroundStyle backgroundStyle = BackgroundStyle.normal;

  bool autoConnect = true;
  bool showStatusBar = true;

  static Locale english = const Locale('en');
  static Locale chinese = const Locale('zh', 'CN');
  ThemeData theme = DefaultThemeData.light();

  Map<String, ThemeData> themeMap = {
    'light': DefaultThemeData.light(),
    'dark': DefaultThemeData.dark(),
  };
  Map<String, Locale> languageMap = {
    'chinese': chinese,
    'english': english,
  };

  // bool get isDarkTheme => theme is DarkTheme;
  Locale locale = chinese;
  ScreenType screenType;
  bool get needShowMenuButton =>
      screenType == ScreenType.phone ||
      (screenType == null && GetPlatform.isAndroid);
  void initConfig() {
    if (Settings.screenType.get != null && Settings.screenType.get.isNotEmpty) {
      screenType = ScreenType.values.byName(Settings.screenType.get);
    }
    if (themeMap.containsKey(Settings.theme.get)) {
      theme = themeMap[Settings.theme.get];
    }
    if (languageMap.containsKey(Settings.language.get)) {
      locale = languageMap[Settings.language.get];
    }
    autoConnect = Settings.autoConnectDevice.get ?? autoConnect;
  }

  void changeScreenType(ScreenType screenType) {
    this.screenType = screenType;
    if (screenType != null) {
      Settings.screenType.set = screenType.name;
    }
    Get.forceAppUpdate();
  }

  void changeLocal(Locale locale) {
    this.locale = locale;
    if (locale == chinese) {
      Settings.language.set = 'chinese';
    } else {
      Settings.language.set = 'english';
    }
    update();
    Get.updateLocale(locale);
  }

  void changeTheme(ThemeData theme) {
    this.theme = theme;
    if (theme.brightness == Brightness.dark) {
      Settings.theme.set = 'dark';
    } else {
      Settings.theme.set = 'light';
    }
    Get.forceAppUpdate();
  }

  void changeStatusBarState(bool value) {
    showStatusBar = value;
    if (!value) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top],
      );
    }
    update();
  }

  void changeAutoConnectState(bool value) {
    autoConnect = value;
    Settings.autoConnectDevice.set = value;
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
