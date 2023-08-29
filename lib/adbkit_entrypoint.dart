// 把init从main函数移动到这儿是有原因的

import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart' hide TabController;
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:window_manager/window_manager.dart';

import 'app/controller/controller.dart';
import 'app/modules/home/views/adaptive_view.dart';
import 'global/instance/global.dart';
import 'material_entrypoint.dart';
import 'themes/lib_color_schemes.g.dart';

class ADBToolEntryPoint extends StatefulWidget {
  const ADBToolEntryPoint({
    Key? key,
    this.primary,
    this.hasSafeArea = true,
    this.showQRCode = true,
  }) : super(key: key);
  // 产品色
  final Color? primary;
  final bool hasSafeArea;
  final bool showQRCode;

  @override
  State<ADBToolEntryPoint> createState() => _ADBToolEntryPointState();
}

class _ADBToolEntryPointState extends State<ADBToolEntryPoint> with WindowListener {
  ConfigController configController = Get.put(ConfigController());
  TabController controller = Get.put(TabController());
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
    // 等待1s
    // await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (widget.primary != null) {
      seed = widget.primary;
    }
    Get.put(DevicesController());
    if (GetPlatform.isDesktop) {
      // Must add this line.
      await windowManager.ensureInitialized();
      WindowOptions windowOptions = const WindowOptions(
        size: Size(800, 600),
        center: false,
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
    setState(() {});
    await Global.instance!.initGlobal();
    Global.instance!.hasSafeArea = widget.hasSafeArea;
    Global.instance!.showQRCode = widget.showQRCode;
    DevicesController controller = Get.find();
    controller.init();
    AppManager.globalInstance;
    isInit = true;
  }

  @override
  void initState() {
    controller.setInitPage(
      PageEntity(
        title: 'ADB KIT',
        page: FutureBuilder(
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
                          color: config.theme!.colorScheme.background,
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
                        data: config.theme!,
                        child: const AdbTool(),
                      );
                    }),
                  ],
                );
            }
          },
        ),
      ),
    );
    super.initState();
  }

  //Create an instance of ScreenshotController

  @override
  Widget build(BuildContext context) {
    return Global().rootWidget ??= GetBuilder<TabController>(
      autoRemove: false,
      builder: (controller) {
        return Column(
          children: [
            TopTab(
              onChanged: (int index) {
                controller.changePage(index);
                Log.d(index);
              },
              children: [
                for (PageEntity page in controller.pages)
                  Text(
                    page.title,
                    style: TextStyle(
                      fontSize: 12.w,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
              ],
            ),
            Builder(builder: (context) {
              print('controller.pageindex -> ${controller.pageindex} controller.pages.length -> ${controller.pages.length}');
              return Expanded(
                child: controller.pages[controller.pageindex].page,
              );
            }),
          ],
        );
      },
    );
  }
}
