import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'app/controller/controller.dart';
import 'app/routes/app_pages.dart';
import 'generated/l10n.dart';
import 'global/instance/global.dart';
import 'material_entrypoint.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  ConfigController configController = Get.put(ConfigController());
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () async {
      await init();
      Get.offAndToNamed(ADBPages.initial);
    });
  }

  bool isInit = false;
  Future<void> init() async {
    if (isInit) {
      return;
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
    await Global().initGlobal();
    DevicesController controller = Get.find();
    controller.init();
    // TODO get依赖不自动移除
    AppManager.globalInstance;
    isInit = true;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            S.current.slogan,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
