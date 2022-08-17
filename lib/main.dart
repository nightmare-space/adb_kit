library adb_tool;

import 'dart:async';
import 'dart:typed_data';
import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/global/instance/plugin_manager.dart';
import 'package:adb_tool/global/widget/mac_safearea.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:app_manager/app_manager.dart' as am;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:window_manager/window_manager.dart';
import 'app/modules/home/views/adaptive_view.dart';
import 'material_entrypoint.dart';
import 'config/config.dart';
import 'core/impl/plugin.dart';
import 'global/instance/global.dart';
import 'themes/lib_color_schemes.g.dart';

// 这个值由shell去替换
bool useNativeShell = false;

Future<void> main() async {
  // Log.d(StackTrace.current);
  // 初始化运行时环境

  PluginManager.instance.register(DashboardPlugin());
  if (!GetPlatform.isWindows) {
    PluginManager.instance.register(AppStarterPlugin());
  }
  PluginManager.instance
    ..register(AppManagerPlugin())
    ..register(AppLauncherPlugin())
    ..register(DeviceInfoPlugin())
    ..register(TaskManagerPlugin());
  runADBClient();
  // PageManager.instance.clear();
  // PageManager.instance.register(Home());
  // PageManager.instance.register(History());
}

void runADBClient({Color primary}) {
  Get.config(
    logWriterCallback: (text, {isError}) {
      Log.d(text, tag: 'GetX');
    },
  );
  if (primary != null) {
    seed = primary;
  }
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      if (!GetPlatform.isIOS) {
        final dir = (await getApplicationSupportDirectory()).path;
        RuntimeEnvir.initEnvirWithPackageName(
          Config.packageName,
          appSupportDirectory: dir,
        );
      }
      runApp(const MaterialAppWrapper());
    },
    (error, stackTrace) {
      Log.e('未捕捉到的异常 : $error \n$stackTrace');
    },
  );
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Log.e('页面构建异常 : ${details.exception}');
  };
  StatusBarUtil.transparent();
}
