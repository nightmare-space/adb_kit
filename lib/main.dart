library adb_tool;

import 'dart:async';
import 'dart:io';
import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/global/drawer/home.dart';
import 'package:adb_tool/global/instance/plugin_manager.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:app_manager/app_manager.dart' as am;
import 'app/modules/home/views/home_view.dart';
import 'app_entrypoint.dart';
import 'config/config.dart';
import 'core/impl/plugin.dart';
import 'global/drawer/history.dart';
import 'global/instance/global.dart';
import 'global/instance/page_manager.dart';
import 'themes/lib_color_schemes.g.dart';

// 这个值由shell去替换
bool useNativeShell = false;

Future<void> main() async {
  // Log.d(StackTrace.current);
  // 初始化运行时环境
  if (!GetPlatform.isIOS) {
    RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  }
  PluginManager.instance
    ..register(DashboardPlugin())
    ..register(AppStarterPlugin())
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
    () {
      runApp(const ADBToolEntryPoint());
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

class ADBToolEntryPoint extends StatefulWidget {
  const ADBToolEntryPoint({Key key, this.primary}) : super(key: key);
  final Color primary;

  @override
  State<ADBToolEntryPoint> createState() => _ADBToolEntryPointState();
}

class _ADBToolEntryPointState extends State<ADBToolEntryPoint> {
  Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (widget.primary != null) {
      seed = widget.primary;
    }
    if (GetPlatform.isDesktop) {
      await Window.initialize();
    }
    await initSetting();
    Get.put(ConfigController());
    Get.put(ConfigController());
    Get.put(DevicesController());
    Global.instance.initGlobal();
    am.AppManager.globalInstance;
    DevicesController controller = Get.find();
    controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: init(),
      builder: (_, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Text('Input a URL to start');
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          case ConnectionState.active:
            return const Text('');
          case ConnectionState.done:
            ConfigController config = Get.find();
            return Theme(
              data: config.theme,
              child: AdbTool(),
            );
        }
        return const SizedBox();
      },
    );
  }
}
