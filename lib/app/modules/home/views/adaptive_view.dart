import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/app/modules/drawer/tablet_drawer.dart';
import 'package:adb_tool/app/modules/privacy_page.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/instance/page_manager.dart';
import 'package:adb_tool/global/widget/mac_safearea.dart';
import 'package:adb_tool/utils/plugin_util.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:screenshot/screenshot.dart';
import 'package:settings/settings.dart';
import 'package:window_manager/window_manager.dart';

import 'dialog/otg_dialog.dart';

class AdbTool extends StatefulWidget {
  const AdbTool({
    Key key,
    this.packageName,
  }) : super(key: key);

  final String packageName;
  @override
  State createState() => _AdbToolState();
}

class _AdbToolState extends State<AdbTool> with WidgetsBindingObserver {
  bool dialogIsShow = false;
  ConfigController configController = Get.find();

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Log.v('didChangeAppLifecycleState : $state');
  }

  @override
  void initState() {
    super.initState();
    if (GetPlatform.isMacOS && RuntimeEnvir.packageName == Config.packageName) {
      // 如果这个项目是独立运行的，那么RuntimeEnvir.packageName会在main函数中被设置成Config.packageName
      Config.flutterPackage = 'packages/adb_tool/';
      Window.makeTitlebarTransparent();
      Window.enableFullSizeContentView();
    }
    configController.syncBackgroundStyle();
    WidgetsBinding.instance.addObserver(this);
    PluginUtil.addHandler((call) {
      if (call.method == 'ShowOTGDialog') {
        dialogIsShow = true;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) {
            return const OTGDialog();
          },
        );
      } else if (call.method == 'CloseOTGDialog') {
        if (dialogIsShow) {
          Navigator.of(context).pop();
        }
        dialogIsShow = false;
      }
    });
    // TODO detach 也需要
    Future.delayed(Duration.zero, () async {
      if ('privacy'.get == null) {
        await Get.to(const PrivacyAgreePage());
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
    Global().page ??= PageManager.instance.pages.first.buildPage(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Theme.of(context).brightness == Brightness.dark
          ? OverlayStyle.light
          : OverlayStyle.dark,
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
            child: Builder(builder: (context) {
              if (ResponsiveWrapper.of(context).isDesktop) {
                return Scaffold(
                  body: Row(
                    children: [
                      DesktopPhoneDrawer(
                        width: Dimens.setWidth(200),
                        groupValue: Global().drawerRoute,
                        onChanged: (value) {
                          Global().page = value;
                          setState(() {});
                        },
                      ),
                      Container(
                        height: double.infinity,
                        width: 0.5,
                        margin: EdgeInsets.symmetric(vertical: 40.w),
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.4),
                      ),
                      Expanded(
                        child: MacSafeArea(
                          child: PageTransitionSwitcher(
                            transitionBuilder: (
                              Widget child,
                              Animation<double> animation,
                              Animation<double> secondaryAnimation,
                            ) {
                              return FadeThroughTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                fillColor: Colors.transparent,
                                child: child,
                              );
                            },
                            duration: const Duration(milliseconds: 300),
                            child: Global().page,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (ResponsiveWrapper.of(context).isTablet) {
                return Scaffold(
                  body: Row(
                    children: [
                      TabletDrawer(
                        groupValue: Global().drawerRoute,
                        onChanged: (value) {
                          Global().page = value;
                          setState(() {});
                        },
                      ),
                      Container(
                        height: double.infinity,
                        width: 1,
                        margin: EdgeInsets.symmetric(vertical: 40.w),
                        color: Theme.of(context)
                            .colorScheme
                            .onBackground
                            .withOpacity(0.1),
                      ),
                      Expanded(
                        child: MacSafeArea(
                          child: PageTransitionSwitcher(
                            transitionBuilder: (
                              Widget child,
                              Animation<double> animation,
                              Animation<double> secondaryAnimation,
                            ) {
                              return FadeThroughTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                fillColor: Colors.transparent,
                                child: child,
                              );
                            },
                            duration: const Duration(milliseconds: 300),
                            child: Global().page,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (ResponsiveWrapper.of(context).isPhone) {
                return Scaffold(
                  drawer: DesktopPhoneDrawer(
                    width: MediaQuery.of(context).size.width * 2 / 3,
                    groupValue: Global().drawerRoute,
                    onChanged: (value) {
                      Global().page = value;
                      setState(() {});
                      Navigator.pop(context);
                    },
                  ),
                  body: MacSafeArea(
                    child: PageTransitionSwitcher(
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                      ) {
                        return FadeThroughTransition(
                          animation: animation,
                          secondaryAnimation: secondaryAnimation,
                          fillColor: Colors.transparent,
                          child: child,
                        );
                      },
                      duration: const Duration(milliseconds: 300),
                      child: Global().page,
                    ),
                  ),
                );
              }
              return const SizedBox();
            }),
          ),
        ],
      ),
    );
  }
}
