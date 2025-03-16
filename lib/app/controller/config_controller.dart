import 'package:adb_kit/config/config.dart';
import 'package:adb_kit/config/settings.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/themes/theme.dart';
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

// TODO 适配英语为跟随系统
enum FileSelecterType {
  saf,
  custom,
}

extension FileSelecterTypeExt on FileSelecterType {
  String get nameIntl {
    switch (this) {
      case FileSelecterType.saf:
        return S.current.systemFileSelecter;
      case FileSelecterType.custom:
        return S.current.customFileSelecter;
    }
  }
}

extension ScreenTypeExt on ScreenType {
  bool get isDesktop => this == ScreenType.desktop;
  bool get isTablet => this == ScreenType.tablet;
  bool get isPhone => this == ScreenType.phone;
}

class ConfigController extends GetxController {
  ConfigController();
  BackgroundStyle backgroundStyle = BackgroundStyle.normal;
  SettingNode themeSetting = Settings.themeSetting;
  SettingNode screenTypeSetting = Settings.screenTypeSetting;

  bool autoConnect = true;
  bool showStatusBar = true;
  String? password;

  static Locale english = const Locale('en');
  static Locale chinese = const Locale('zh', 'CN');
  ThemeData? theme = light();
  ThemeMode themeMode = ThemeMode.light;

  FileSelecterType fileSelecterType = FileSelecterType.custom;

  Map<String, ThemeData?> themeMap = {
    ThemeMode.light.name: light(),
    ThemeMode.dark.name: dark(),
    ThemeMode.system.name: null,
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
    Settings.backgroundStyle.setting.set(backgroundStyle.name);
    update();
    syncBackgroundStyle();
  }

  // bool get isDarkTheme => theme is DarkTheme;
  Locale? locale;
  ScreenType? screenType;
  bool get needShowMenuButton => screenType == ScreenType.phone || (screenType == null && GetPlatform.isAndroid);

  bool isInit = false;
  void initConfig() {
    if (isInit) {
      return;
    }
    Log.i('initConfig');
    isInit = true;
    if (screenTypeSetting.value != null && screenTypeSetting.value.isNotEmpty) {
      screenType = ScreenType.values.byName(screenTypeSetting.value);
    }
    if (Settings.backgroundStyleSetting.value != null) {
      backgroundStyle = BackgroundStyle.values.byName(Settings.backgroundStyleSetting.value);
    }
    Log.i('themeSetting.value -> ${themeSetting.value}');
    if (themeMap.containsKey(themeSetting.value)) {
      themeMode = ThemeMode.values.byName(themeSetting.value);
      theme = themeMap[themeSetting.value];
      Log.i('theme -> $theme themeMode -> $themeMode');
    }
    if (languageMap.containsKey(Settings.languageSetting.value)) {
      locale = languageMap[Settings.languageSetting.value];
    }
    autoConnect = Settings.autoConnectDeviceSetting.value ?? autoConnect;
    password = Settings.adbPasswordSetting.value ?? password;
    if (Settings.fileSelecterTypeSetting.value != null) {
      fileSelecterType = FileSelecterType.values.byName(Settings.fileSelecterTypeSetting.value);
    }
  }

  void changePassword(String password) {
    Settings.adbPasswordSetting.set(password);
    this.password = password;
    update();
  }

  void changeScreenType(ScreenType? screenType) {
    this.screenType = screenType;
    screenTypeSetting.set(screenType?.name);
    update();
  }

  void changeFileSelecterType(FileSelecterType type) {
    fileSelecterType = type;
    Settings.fileSelecterTypeSetting.set(type.name);
    update();
  }

  void changeLocal(Locale locale) {
    this.locale = locale;
    if (locale == chinese) {
      Settings.language.setting.set('chinese');
    } else {
      Settings.language.setting.set('english');
    }
    update();
  }

  void changeTheme(int index) {
    themeMode = ThemeMode.values[index];
    switch (themeMode) {
      case ThemeMode.dark:
        theme = dark();
        break;
      case ThemeMode.light:
        theme = light();
        break;
      case ThemeMode.system:
        theme = null;
        break;
    }
    themeSetting.set(themeMode.name);
    Log.i('changeTheme -> ${themeSetting.value}');
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
    Settings.autoConnectDevice.setting.set(value);
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
    final String? newPath = await showMenu<String>(
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
    if (newPath != null) {
      Settings.serverPath.setting.set(newPath);
    }
  }
}
