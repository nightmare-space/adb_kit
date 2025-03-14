import 'package:adb_kit/adb_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:settings/settings.dart';
import 'drawer/drawer.dart';
import 'views/desktop_home.dart';
import 'views/mobile_home.dart';
import 'views/tablet_home.dart';

typedef RouteCallback = void Function(String route);

class ADBKITAdaptiveRootWidget extends StatefulWidget {
  const ADBKITAdaptiveRootWidget({
    super.key,
    this.packageName,
  });

  final String? packageName;
  @override
  State createState() => _ADBKITAdaptiveRootWidgetState();
}

class _ADBKITAdaptiveRootWidgetState extends State<ADBKITAdaptiveRootWidget> {
  ConfigController configController = Get.find();
  int index = 0;
  String route = 'home';

  @override
  void initState() {
    super.initState();
    // configController.syncBackgroundStyle();
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

  void onChanged(String route) {
    this.route = route;
    if (ResponsiveBreakpoints.of(context).isMobile) {
      Navigator.of(context).pop();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final drawer = NiDrawer(
      items: [
        NiDrawerItem<String>(
          value: DrawerRoutes.home,
          groupValue: route,
          mini: Icon(Icons.home),
          title: Text(S.current.home),
        ),
        // history
        NiDrawerItem<String>(
          value: DrawerRoutes.history,
          groupValue: route,
          mini: Icon(Icons.history),
          title: Text(S.current.historyConnect),
        ),
        // signal_wifi_4_bar
        // if (GetPlatform.isAndroid)
        // NiDrawerItem<String>(
        //   value: DrawerRoutes.networkDebug,
        //   groupValue: route,
        //   mini: Icon(Icons.signal_wifi_4_bar),
        //   title: Text(S.current.networkDebug),
        // ),
        // code
        NiDrawerItem<String>(
          value: DrawerRoutes.terminal,
          groupValue: route,
          mini: Icon(Icons.code),
          title: Text(S.current.terminal),
        ),
        // pending_outlined
        NiDrawerItem<String>(
          value: DrawerRoutes.log,
          groupValue: route,
          mini: Icon(Icons.pending_outlined),
          title: Text(S.current.log),
        ),
        // settings
        NiDrawerItem<String>(
          value: DrawerRoutes.setting,
          groupValue: route,
          mini: Icon(Icons.settings),
          title: Text(S.current.setting),
        ),
        // info_outline
        NiDrawerItem<String>(
          value: DrawerRoutes.about,
          groupValue: route,
          mini: Icon(Icons.info_outline),
          title: Text(S.current.about),
        ),
      ],
      onChanged: onChanged,
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // TODO(lin):?
      value: Theme.of(context).brightness == Brightness.dark
          ? OverlayStyle.light
          : SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: Theme.of(context).scaffoldBackgroundColor,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
      child: Builder(
        builder: (context) {
          if (ResponsiveBreakpoints.of(context).isDesktop || (configController.screenType?.isDesktop ?? false)) {
            return DesktopHome(route: route, drawer: drawer);
          }
          if (ResponsiveBreakpoints.of(context).isTablet || (configController.screenType?.isTablet ?? false)) {
            return TabletHome(route: route, drawer: drawer);
          }
          if (ResponsiveBreakpoints.of(context).isMobile || (configController.screenType?.isPhone ?? false)) {
            return MobileHome(route: route, drawer: drawer);
          }
          return const SizedBox();
        },
      ),
    );
  }
}
