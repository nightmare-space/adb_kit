library adb_tool;

import 'dart:async';
import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/global/instance/plugin_manager.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:app_manager/app_manager.dart' as am;
import 'package:responsive_framework/responsive_framework.dart';
import 'app/modules/home/views/adaptive_view.dart';
import 'app_entrypoint.dart';
import 'config/config.dart';
import 'core/impl/plugin.dart';
import 'global/instance/global.dart';
import 'themes/lib_color_schemes.g.dart';

// 这个值由shell去替换
bool useNativeShell = false;

Future<void> main() async {
  // Log.d(StackTrace.current);
  // 初始化运行时环境
  if (!GetPlatform.isIOS) {
    RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  }
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
    () {
      WidgetsFlutterBinding.ensureInitialized();
      runApp(const MaterialAppWrapper());
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

// 把init从main函数移动到这儿是有原因的
class ADBToolEntryPoint extends StatefulWidget {
  const ADBToolEntryPoint({
    Key key,
    this.primary,
    this.hasSafeArea = true,
    this.showQRCode = true,
  }) : super(key: key);
  // 产品色
  final Color primary;
  final bool hasSafeArea;
  final bool showQRCode;

  @override
  State<ADBToolEntryPoint> createState() => _ADBToolEntryPointState();
}

class _ADBToolEntryPointState extends State<ADBToolEntryPoint> {
  bool isInit = false;
  Future<void> init() async {
    if (isInit) {
      return;
    }
    if (widget.primary != null) {
      seed = widget.primary;
    }
    ConfigController configController = Get.put(ConfigController());
    Get.put(DevicesController());
    WidgetsFlutterBinding.ensureInitialized();

    if (GetPlatform.isDesktop) {
      await Window.initialize();
    }
    await initSetting();
    configController.initConfig();
    Global.instance.initGlobal();
    Global.instance.hasSafeArea = widget.hasSafeArea;
    Global.instance.showQRCode = widget.showQRCode;
    am.AppManager.globalInstance;
    DevicesController controller = Get.find();
    controller.init();
    isInit = true;
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
            return Stack(
              children: [
                GetBuilder<ConfigController>(builder: (config) {
                  if (config.backgroundStyle == BackgroundStyle.normal) {
                    return Container(
                      color: config.theme.colorScheme.background,
                    );
                  }
                  if (config.backgroundStyle == BackgroundStyle.image) {
                    return SizedBox(
                      height: double.infinity,
                      child: Image.asset(
                        'assets/b.png',
                        fit: BoxFit.cover,
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                }),
                GetBuilder<ConfigController>(builder: (config) {
                  return Theme(
                    data: config.theme,
                    child: const AdbTool(),
                  );
                  return ResponsiveWrapper.builder(
                    Builder(builder: (context) {
                      if (ResponsiveWrapper.of(context).isDesktop) {
                        ScreenAdapter.init(896);
                      } else {
                        ScreenAdapter.init(414);
                      }
                      return Theme(
                        data: config.theme,
                        child: const AdbTool(),
                      );
                    }),
                    // maxWidth: 1200,
                    minWidth: 10,
                    defaultScale: true,
                    defaultName: PHONE,
                    breakpoints: const [
                      ResponsiveBreakpoint.resize(600, name: TABLET),
                      ResponsiveBreakpoint.resize(1000, name: DESKTOP),
                    ],
                  );
                }),
              ],
            );
        }
        return const SizedBox();
      },
    );
  }
}
