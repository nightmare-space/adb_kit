import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/app/modules/drawer/tablet_drawer.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/instance/page_manager.dart';
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
  }) : super(key: key) {
    // ! 换位置

  }

  final String packageName;
  @override
  _AdbToolState createState() => _AdbToolState();
}

class _AdbToolState extends State<AdbTool> with WidgetsBindingObserver {
  bool dialogIsShow = false;
  ConfigController configController = Get.find();
  Widget page;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    Log.v('didChangeAppLifecycleState : $state');
  }

  @override
  void initState() {
    super.initState();
    if (GetPlatform.isMacOS) {
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
  }

  @override
  void dispose() {
    Log.w('ADB TOOL dispose');
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    page ??= PageManager.instance.pages.first.buildPage(context);
    return Stack(
      children: [
        AnnotatedRegion<SystemUiOverlayStyle>(
          value: Theme.of(context).brightness == Brightness.dark
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
                          groupValue: Global().drawerRoute,
                          onChanged: (value) {
                            page = value;
                            setState(() {});
                          },
                        ),
                        Expanded(
                          child: TitlebarSafeArea(
                            child: page,
                          ),
                        ),
                      ],
                    ),
                  );
                  break;
                case ScreenType.tablet:
                  return Scaffold(
                    body: Row(
                      children: [
                        TabletDrawer(
                          groupValue: Global().drawerRoute,
                          onChanged: (value) {
                            page = value;
                            setState(() {});
                          },
                        ),
                        Expanded(
                          child: TitlebarSafeArea(
                            child: page,
                          ),
                        ),
                      ],
                    ),
                  );
                  break;
                case ScreenType.phone:
                  return Scaffold(
                    drawer: DesktopPhoneDrawer(
                      width: MediaQuery.of(context).size.width * 2 / 3,
                      groupValue: Global().drawerRoute,
                      onChanged: (value) {
                        page = value;
                        setState(() {});
                        Navigator.pop(context);
                      },
                    ),
                    body: page,
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
