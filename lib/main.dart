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

class _ADBToolEntryPointState extends State<ADBToolEntryPoint>
    with WindowListener {
  ConfigController configController = Get.put(ConfigController());
  @override
  void onWindowFocus() {
    // Make sure to call once.
    setState(() {});
    // do something
  }

  bool isInit = false;
  Future<void> init() async {
    if (isInit) {
      return;
    }
    if (widget.primary != null) {
      seed = widget.primary;
    }
    Get.put(DevicesController());
    WidgetsFlutterBinding.ensureInitialized();

    if (GetPlatform.isDesktop) {
      await Window.initialize();
      // Must add this line.
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = WindowOptions(
        size: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
      );
      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
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

  Uint8List _imageFile;

  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: screenshotController,
      child: RawKeyboardListener(
        autofocus: true,
        focusNode: FocusNode(),
        onKey: ((value) {
          Log.w(value);
          if (value is RawKeyDownEvent) {
            screenshotController.captureAndSave('./home.png');
          }
        }),
        child: Column(
          children: [
            Center(
              child: Container(
                color: configController.theme.colorScheme.background,
                width: double.infinity,
                height: 24,
                child: DragToMoveArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      WindowCaptionButton.minimize(
                        onPressed: () {
                          windowManager.minimize();
                        },
                      ),
                      WindowCaptionButton.maximize(
                        onPressed: () {
                          windowManager.maximize();
                        },
                      ),
                      WindowCaptionButton.close(
                        onPressed: () {
                          windowManager.close();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
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
                            if (config.backgroundStyle ==
                                BackgroundStyle.normal) {
                              return Container(
                                color: config.theme.colorScheme.background,
                              );
                            }
                            if (config.backgroundStyle ==
                                BackgroundStyle.image) {
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
                          }),
                        ],
                      );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
