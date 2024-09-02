library adb_tool;

import 'dart:async';
import 'dart:ui';
import 'package:adb_kit/global/instance/plugin_manager.dart';
import 'package:file_manager_view/file_manager_view.dart' hide Config;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'generated/l10n.dart';
import 'material_entrypoint.dart';
import 'config/config.dart';
import 'plugins/plugin.dart';
import 'package:adb_kit_extension/adb_kit_extension.dart';

Future<void> main() async {
  // 初始化运行时环境
  Future.delayed(const Duration(milliseconds: 1000), () {
    PluginManager.instance
      ..registerADBPlugin(DashboardPlugin())
      ..registerADBPlugin(AppStarterPlugin())
      ..registerADBPlugin(AppManagerPlugin())
      ..registerADBPlugin(DeviceInfoPlugin())
      ..registerADBPlugin(ProcessPlugin())
      ..registerADBPlugin(TaskManagerPlugin());
  });
  runADBClient();
}

Future<void> runADBClient() async {
  // hook getx log
  Get.config(
    enableLog: false,
    logWriterCallback: (text, {bool? isError}) {
      Log.d(text, tag: 'GetX');
    },
  );
  // 启动文件管理器服务，以供 ADB KIT 选择本机文件
  Server.start();
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      initPersonal();
      if (!GetPlatform.isIOS) {
        final dir = (await getApplicationSupportDirectory()).path;
        RuntimeEnvir.initEnvirWithPackageName(
          Config.packageName,
          appSupportDirectory: dir,
        );
      }
      await initSetting();
      runApp(const MaterialAppWrapper());
    },
    (error, stackTrace) {
      Log.e('${S.current.uncaughtDE} -> $error \n$stackTrace');
    },
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        parent.print(zone, line);
        // Log.d(line);
      },
    ),
  );
  DartPluginRegistrant.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Log.e('${S.current.uncaughtUE} -> ${details.exception}');
  };
  StatusBarUtil.transparent();
}
