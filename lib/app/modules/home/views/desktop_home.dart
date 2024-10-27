import 'package:adb_kit/app/modules/drawer/drawer.dart';
import 'package:adb_kit/app/modules/drawer/drawer_desktop_phone.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class DesktopHome extends StatefulWidget {
  const DesktopHome({
    super.key,
    required this.page,
    required this.onChanged,
  });
  final Widget page;
  final void Function(int index) onChanged;

  @override
  State<DesktopHome> createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          DesktopPhoneDrawer(
            width: Dimens.setWidth(200),
            groupValue: drawerRoute,
            onChanged: widget.onChanged,
          ),
          Container(
            height: double.infinity,
            width: 0.5,
            margin: EdgeInsets.symmetric(vertical: 40.w),
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
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
              child: widget.page,
            ),
          ),
        ],
      ),
    );
  }
}
