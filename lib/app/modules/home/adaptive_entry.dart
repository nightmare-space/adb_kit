import 'package:adb_kit/adb_kit.dart';
import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/config/config.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:adb_kit/global/instance/page_manager.dart';
import 'package:adb_kit/utils/plugin_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:settings/settings.dart';

import 'views/desktop_home.dart';
import 'views/mobile_home.dart';
import 'views/tablet_home.dart';

class ADBKITAdaptiveRootWidget extends StatefulWidget {
  const ADBKITAdaptiveRootWidget({
    Key? key,
    this.packageName,
  }) : super(key: key);

  final String? packageName;
  @override
  State createState() => _ADBKITAdaptiveRootWidgetState();
}

class _ADBKITAdaptiveRootWidgetState extends State<ADBKITAdaptiveRootWidget> with WidgetsBindingObserver {
  bool dialogIsShow = false;
  ConfigController configController = Get.find();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Log.v('didChangeAppLifecycleState : $state');
  }

  @override
  void initState() {
    super.initState();
    // TODO 这个代码不应该放在这
    if (GetPlatform.isMacOS && RuntimeEnvir.packageName == Config.packageName) {
      // 如果这个项目是独立运行的，那么RuntimeEnvir.packageName会在main函数中被设置成Config.packageName
      Config.flutterPackage = 'packages/adb_tool/';
      // Window.makeTitlebarTransparent();
      // Window.enableFullSizeContentView();
    }
    configController.syncBackgroundStyle();
    WidgetsBinding.instance.addObserver(this);

    // TODO 隐私协议不应该和某个Widget挂在一起
    Future.delayed(Duration.zero, () async {
      if ('privacy'.setting.get() == null) {
        await Get.to(PrivacyAgreePage(
          onAgreeTap: () {
            'privacy'.setting.set(true);
            Navigator.of(context).pop();
          },
        ));
      }
    });
  }

  @override
  void dispose() {
    Log.w('ADB TOOL dispose');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Global().page ??= PageManager.instance!.pages.first.buildPage(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? OverlayStyle.light
          : SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
      child: Stack(
        children: [
          Builder(
            builder: (context) {
              // TODO bug
              if (ResponsiveBreakpoints.of(context).isDesktop || (configController.screenType?.isDesktop ?? false)) {
                return const DesktopHome();
              }
              if (ResponsiveBreakpoints.of(context).isTablet || (configController.screenType?.isTablet ?? false)) {
                return const TableHome();
              }
              if (ResponsiveBreakpoints.of(context).isMobile || (configController.screenType?.isPhone ?? false)) {
                return const MobileHome();
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
