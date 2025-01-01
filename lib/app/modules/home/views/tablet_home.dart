import 'package:adb_kit/app/modules/home/adaptive_entry.dart';
import 'package:adb_kit/app/modules/home/drawer/drawer.dart';
import 'package:adb_kit/app/modules/home/drawer/drawer_tablet.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class TabletHome extends StatefulWidget {
  const TabletHome({
    super.key,
    required this.route,
    required this.onChanged,
  });
  final String route;
  final RouteCallback? onChanged;

  @override
  State<TabletHome> createState() => _TabletHomeState();
}

class _TabletHomeState extends State<TabletHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          TabletDrawer(
            route: widget.route,
            onChanged: widget.onChanged,
          ),
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
