import 'package:adb_kit/app/modules/home/drawer/drawer.dart';
import 'package:adb_kit/app/modules/home/drawer/drawer_desktop_phone.dart';
import 'package:adb_kit/app/modules/home/adaptive_entry.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class DesktopHome extends StatefulWidget {
  const DesktopHome({
    super.key,
    required this.route,
    required this.onChanged,
  });
  final String route;
  final RouteCallback onChanged;

  @override
  State<DesktopHome> createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  @override
  Widget build(BuildContext context) {
    Row row = Row(
      children: [
        DesktopPhoneDrawer(
          width: 200.w,
          groupValue: widget.route,
          onChanged: widget.onChanged,
        ),
        Container(
          height: double.infinity,
          width: 0.5,
          margin: EdgeInsets.symmetric(vertical: 40.w),
          color: Theme.of(context).colorScheme.onSurface.withAlpha(opacity04),
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
    );
    return Scaffold(body: row);
  }
}
