import 'dart:ui';

import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/app/modules/drawer/tablet_drawer.dart';
import 'package:adb_tool/app/routes/app_pages.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:adb_tool/utils/plugin_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';

import 'dialog/otg_dialog.dart';

class AdbTool extends StatefulWidget {
  AdbTool({
    Key key,
    this.packageName,
    this.initRoute = Routes.overview,
  }) : super(key: key) {
    if (RuntimeEnvir.packageName != Config.packageName &&
        !GetPlatform.isDesktop) {
      // 如果这个项目是独立运行的，那么RuntimeEnvir.packageName会在main函数中被设置成Config.packageName
      Config.flutterPackage = 'packages/adb_tool/';
    }
  }

  final String packageName;
  final String initRoute;
  @override
  _AdbToolState createState() => _AdbToolState();
}

class _AdbToolState extends State<AdbTool> with WidgetsBindingObserver {
  String route;
  bool dialogIsShow = false;
  ConfigController configController = Get.find();
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Log.v('didChangeAppLifecycleState : $state');
  }

  @override
  void initState() {
    super.initState();
    route = widget.initRoute;
    if (GetPlatform.isMacOS) {
      Window.makeTitlebarTransparent();
      Window.enableFullSizeContentView();
    }
    Window.setEffect(
      effect: WindowEffect.aero,
      color: Colors.transparent,
      dark: false,
    );
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
  }

  @override
  void dispose() {
    Log.w('ADB TOOL dispose');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TitlebarSafeArea();
    return Stack(
      children: [
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: configController.theme is DarkTheme
              ? OverlayStyle.light
              : OverlayStyle.dark,
          child: Responsive(
            builder: (_, ScreenType screenType) {
              ScreenType type = configController.screenType;
              switch (type ?? screenType) {
                case ScreenType.desktop:
                  return Scaffold(
                    body: Row(
                      children: [
                        DesktopPhoneDrawer(
                          width: Dimens.setWidth(200),
                          groupValue: route,
                          onChanged: (value) {
                            route = value;
                            setState(() {});
                          },
                        ),
                        Expanded(child: getWidget(route)),
                      ],
                    ),
                  );
                  break;
                case ScreenType.tablet:
                  return Scaffold(
                    // backgroundColor: Colors.transparent,
                    body: Row(
                      children: [
                        TabletDrawer(
                          groupValue: route,
                          onChanged: (index) {
                            route = index;
                            setState(() {});
                          },
                        ),
                        Expanded(child: getWidget(route)),
                      ],
                    ),
                  );
                  break;
                case ScreenType.phone:
                  return Scaffold(
                    backgroundColor: configController.theme.background,
                    drawer: DesktopPhoneDrawer(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      groupValue: route,
                      onChanged: (value) {
                        route = value;
                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),
                    body: Row(
                      children: [
                        Expanded(child: getWidget(route)),
                      ],
                    ),
                  );
                  break;
                default:
                  return const Text('ERROR');
              }
            },
          ),
        ),
      ],
    );
  }
}
