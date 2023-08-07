library adb_tool;

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:adb_kit/global/instance/plugin_manager.dart';
import 'package:file_manager_view/file_manager_view.dart' hide Config;
// import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'material_entrypoint.dart';
import 'config/config.dart';
import 'plugins/plugin.dart';
import 'themes/lib_color_schemes.g.dart';
import 'package:adb_kit_extension/adb_kit_extension.dart';

// 这个值由shell去替换
bool useNativeShell = false;

Future<void> main() async {
  // Log.d(StackTrace.current);
  // 初始化运行时环境
  Future.delayed(const Duration(milliseconds: 1000), () {
    PluginManager.instance.registerADBPlugin(DashboardPlugin());
    PluginManager.instance.registerADBPlugin(AppStarterPlugin());
    PluginManager.instance
      ..registerADBPlugin(AppManagerPlugin())
      // ..registerADBPlugin(AppLauncherPlugin())
      ..registerADBPlugin(DeviceInfoPlugin())
      ..registerADBPlugin(ProcessPlugin())
      ..registerADBPlugin(TaskManagerPlugin());
  });
  runADBClient();
  // PageManager.instance.clear();
  // PageManager.instance.register(Home());
  // PageManager.instance.register(History());
}

Future<void> runADBClient({Color? primary}) async {
  // hook getx log
  Get.config(
    enableLog: false,
    logWriterCallback: (text, {bool? isError}) {
      // Log.d(text, tag: 'GetX');
    },
  );
  // set primary color
  if (primary != null) {
    seed = primary;
  }
  // // 启动文件管理器服务，以供 ADB KIT 选择本机文件
  Server.start();
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      initPersonal();
      if (!GetPlatform.isIOS) {
        // ios
        final dir = (await getApplicationSupportDirectory()).path;
        RuntimeEnvir.initEnvirWithPackageName(
          Config.packageName,
          appSupportDirectory: dir,
        );
      }
      // if (GetPlatform.isDesktop) {
      //   await Window.initialize();
      // }
      runApp(const MaterialAppWrapper());
    },
    (error, stackTrace) {
      Log.e('未捕捉到的异常 : $error \n$stackTrace');
    },
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        parent.print(zone, line);
        // Log.d(line);
      },
    ),
  );
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Log.e('页面构建异常 : ${details.exception}');
  };
  StatusBarUtil.transparent();
}
