library adb_tool;

import 'dart:async';
import 'package:adb_tool/global/drawer/home.dart';
import 'package:adb_tool/global/instance/plugin_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:app_manager/app_manager.dart' as am;
import 'app_entrypoint.dart';
import 'config/config.dart';
import 'core/impl/plugin.dart';
import 'global/drawer/history.dart';
import 'global/instance/global.dart';
import 'global/instance/page_manager.dart';

// 这个值由shell去替换
bool useNativeShell = false;

Future<void> main() async {
  // Log.d(StackTrace.current);

  PluginManager.instance
    ..register(DashboardPlugin())
    ..register(AppStarterPlugin())
    ..register(AppManagerPlugin())
    ..register(AppLauncherPlugin())
    ..register(DeviceInfoPlugin())
    ..register(TaskManagerPlugin());
  runADBClient();
  PageManager.instance.clear();
  PageManager.instance.register(Home());
  PageManager.instance.register(History());
}

void runADBClient() {
  Get.config(
    logWriterCallback: (text, {isError}) {
      Log.d(text, tag: 'GetX');
    },
  );
  // 初始化运行时环境
  if (!GetPlatform.isIOS) {
    RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  }
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
  StatusBarUtil.transparent();
}
