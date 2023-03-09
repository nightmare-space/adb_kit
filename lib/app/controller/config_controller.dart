import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/config/settings.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:settings/settings.dart';

enum BackgroundStyle {
  normal,
  image,
  tranparent,
}

class ConfigController extends GetxController {
  ConfigController();
  BackgroundStyle backgroundStyle = BackgroundStyle.normal;

  bool autoConnect = true;
  bool showStatusBar = true;

  static Locale english = const Locale('en');
  static Locale chinese = const Locale('zh', 'CN');
  ThemeData? theme = DefaultThemeData.light();

  Map<String, ThemeData> themeMap = {
    'light': DefaultThemeData.light(),
    'dark': DefaultThemeData.dark(),
  };
  Map<String, Locale> languageMap = {
    'chinese': chinese,
    'english': english,
  };

  void syncBackgroundStyle() {
    // if (backgroundStyle == BackgroundStyle.normal) {
    //   if (GetPlatform.isWindows || GetPlatform.isLinux) {
    //     return;
    //   }
    //   Window.setEffect(
    //     effect: WindowEffect.disabled,
    //     color: theme.colorScheme.background,
    //     dark: false,
    //   );
    // }
    // if (backgroundStyle == BackgroundStyle.image) {
    //   Window.setEffect(
    //     effect: WindowEffect.disabled,
    //     color: theme.colorScheme.background.withOpacity(0.2),
    //     dark: false,
    //   );
    // } else {
    //   Window.setEffect(
    //     effect: WindowEffect.acrylic,
    //     color: theme.colorScheme.background.withOpacity(0.2),
    //     dark: false,
    //   );
    // }
  }

  void changeBackgroundStyle(BackgroundStyle style) {
    backgroundStyle = style;
    Settings.backgroundStyle.set = backgroundStyle.name;
    update();
    syncBackgroundStyle();
  }

  // bool get isDarkTheme => theme is DarkTheme;
  Locale? locale = chinese;
  ScreenType? screenType;
  bool get needShowMenuButton => screenType == ScreenType.phone || (screenType == null && GetPlatform.isAndroid);

  bool isInit = false;
  void initConfig() {
    if (isInit) {
      return;
    }
    isInit = true;
    if (Settings.screenType.get != null && Settings.screenType.get.isNotEmpty) {
      screenType = ScreenType.values.byName(Settings.screenType.get);
    }
    if (Settings.backgroundStyle.get != null) {
      backgroundStyle = BackgroundStyle.values.byName(
        Settings.backgroundStyle.get,
      );
    }
    if (themeMap.containsKey(Settings.theme.get)) {
      theme = themeMap[Settings.theme.get];
    }
    if (languageMap.containsKey(Settings.language.get)) {
      locale = languageMap[Settings.language.get];
    }

    autoConnect = Settings.autoConnectDevice.get ?? autoConnect;
  }

  void changeScreenType(ScreenType? screenType) {
    this.screenType = screenType;
    if (screenType != null) {
      Settings.screenType.set = screenType.name;
    }
    update();
  }

  void changeLocal(Locale locale) {
    this.locale = locale;
    if (locale == chinese) {
      Settings.language.set = 'chinese';
    } else {
      Settings.language.set = 'english';
    }
    update();
  }

  void changeTheme(ThemeData theme) {
    this.theme = theme;
    if (theme.brightness == Brightness.dark) {
      Settings.theme.set = 'dark';
    } else {
      Settings.theme.set = 'light';
    }
    update();
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

  Future<void> changeServerPath(BuildContext context) async {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Offset offset = renderBox.localToGlobal(renderBox.size.center(Offset.zero));
    final List<PopupMenuEntry<String>> items = <PopupMenuEntry<String>>[];
    for (final String path in <String>[
      Config.adbLocalPath,
      Config.sdcard,
    ]) {
      items.add(PopupMenuItem<String>(
        value: path,
        child: Text(path),
      ));
    }
    final String? newPartition = await showMenu<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      position: RelativeRect.fromLTRB(offset.dx - offset.dx / 2, offset.dy, MediaQuery.of(context).size.width, 0.0),
      items: items,
      elevation: 0,
    );
    if (newPartition != null) {
      Settings.serverPath.set = newPartition;
    }
  }
}
