library adb_tool;

import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui';
import 'package:adb_tool/global/instance/plugin_manager.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/modules/log_page.dart';
import 'package:adb_tool/config/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:nativeshell/nativeshell.dart' as nativeshell;
import 'package:app_manager/app_manager.dart' as am;
import 'package:settings/settings.dart';
import 'app/controller/devices_controller.dart';
import 'app/routes/app_pages.dart';
import 'app_entrypoint.dart';
import 'config/config.dart';
import 'core/impl/plugin.dart';
import 'generated/l10n.dart';
import 'global/instance/global.dart';
import 'themes/app_colors.dart';
import 'themes/theme.dart';
import 'utils/fps.dart';

// 这个值由shell去替换
bool useNativeShell = false;

Future<void> main() async {
  // 初始化运行时环境
  if (!GetPlatform.isIOS) {
    RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  }
  // Log.d(StackTrace.current);
  Get.config(
    logWriterCallback: (text, {isError}) {
      Log.d(text, tag: 'GetX');
    },
  );
  PluginManager.instance
    ..register(DashboardPlugin())
    ..register(AppStarterPlugin())
    ..register(AppManagerPlugin())
    ..register(AppLauncherPlugin())
    ..register(DeviceInfoPlugin())
    ..register(TaskManagerPlugin());
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      if (GetPlatform.isDesktop) {
        await Window.initialize();
      }
      await initSetting();
      Get.put(ConfigController());
      Global.instance.initGlobal();
      am.AppManager.globalInstance;
      if (useNativeShell) {
        runApp(const NativeShellWrapper());
      } else {
        runApp(const AppEntryPoint());
      }
    },
    (error, stackTrace) {
      Log.e('未捕捉到的异常 : $error');
    },
  );
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Log.e('页面构建异常 : ${details.exception}');
  };
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}
