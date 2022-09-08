// 把init从main函数移动到这儿是有原因的

import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'app/controller/controller.dart';
import 'app/modules/home/views/adaptive_view.dart';
import 'global/instance/global.dart';
import 'material_entrypoint.dart';
import 'themes/lib_color_schemes.g.dart';

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
      // Must add this line.
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(800, 600),
        center: true,
        backgroundColor: Colors.transparent,
        skipTaskbar: false,
        titleBarStyle: TitleBarStyle.hidden,
        minimumSize: Size(400, 300),
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
    AppManager.globalInstance;
    DevicesController controller = Get.find();
    controller.init();
    isInit = true;
  }

  //Create an instance of ScreenshotController

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                      }),
                    ],
                  );
              }
              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
