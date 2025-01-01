import 'package:adb_kit/adb_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:settings/settings.dart';
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
  String route = S.current.home;

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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
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
            return DesktopHome(route: route, onChanged: onChanged);
          }
          if (ResponsiveBreakpoints.of(context).isTablet || (configController.screenType?.isTablet ?? false)) {
            return TabletHome(route: route, onChanged: onChanged);
          }
          if (ResponsiveBreakpoints.of(context).isMobile || (configController.screenType?.isPhone ?? false)) {
            return MobileHome(route: route, onChanged: onChanged);
          }
          return const SizedBox();
        },
      ),
    );
  }
}
