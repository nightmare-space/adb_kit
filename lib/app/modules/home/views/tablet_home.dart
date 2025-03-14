import 'package:adb_kit/app/modules/home/adaptive_entry.dart';
import 'package:adb_kit/app/modules/home/drawer/drawer.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class DrawerRoutes {
  static const String home = 'home';
  static const String history = 'history';
  // static const String networkDebug = 'networkDebug';
  static const String terminal = 'terminal';
  static const String log = 'log';
  static const String setting = 'setting';
  static const String about = 'about';
}

class TabletHome extends StatefulWidget {
  const TabletHome({
    super.key,
    required this.route,
    required this.drawer,
  });
  final String route;
  final NiDrawer drawer;

  @override
  State<TabletHome> createState() => _TabletHomeState();
}

class _TabletHomeState extends State<TabletHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          widget.drawer,
          // Builder(builder: (context) {
          //   return Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 8.w),
          //     child: InkWell(
          //       borderRadius: BorderRadius.circular(8.w),
          //       onTap: () {
          //         ThemeData theme = light(primary: Theme.of(context).primaryColor);
          //         if (Theme.of(context).brightness == Brightness.light) {
          //           theme = dark();
          //         }
          //         if (theme.brightness == Brightness.dark) {
          //           Settings.theme.setting.set('dark');
          //         } else {
          //           Settings.theme.setting.set('light');
          //         }
          //         ConfigController controller = Get.find();
          //         controller.theme = theme;
          //         Navigator.of(context).pushReplacement(
          //           RippleRoute(
          //             GetBuilder<ConfigController>(
          //               builder: (context) {
          //                 return Theme(data: context.theme!, child: Global().rootWidget!);
          //               },
          //             ),
          //             RouteConfig.fromContext(context),
          //           ),
          //         );
          //       },
          //       child: TabletDrawerItem(
          //         groupValue: widget.route,
          //         title: S.current.switchTheme,
          //         iconData: Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
          //       ),
          //     ),
          //   );
          // }),
          Container(
            height: double.infinity,
            width: 1,
            margin: EdgeInsets.symmetric(vertical: 40.w),
            color: Theme.of(context).colorScheme.onSurface.withAlpha(opacity01),
          ),
          Expanded(
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
              child: drawerPages(widget.route),
            ),
          ),
        ],
      ),
    );
  }
}
