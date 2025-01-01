import 'package:adb_kit/app/modules/home/drawer/drawer.dart';
import 'package:adb_kit/app/modules/home/drawer/drawer_desktop_phone.dart';
import 'package:adb_kit/app/modules/home/adaptive_entry.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({
    super.key,
    this.onChanged,
    required this.route,
  });
  final RouteCallback? onChanged;
  final String route;

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  @override
  Widget build(BuildContext context) {
    Widget drawer = DesktopPhoneDrawer(
      width: Get.mediaQuery.size.width * 2 / 3,
      groupValue: widget.route,
      onChanged: (value) {
        widget.onChanged?.call(value);
        Navigator.pop(context);
      },
    );
    Widget body = PageTransitionSwitcher(
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
      duration: mill300,
      child: drawerPages(widget.route),
    );
    return Scaffold(drawer: drawer, body: body);
  }
}

const Duration mill300 = Duration(microseconds: 300);
