import 'package:adb_kit/app/modules/drawer/drawer.dart';
import 'package:adb_kit/app/modules/drawer/drawer_tablet.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class TabletHome extends StatefulWidget {
  const TabletHome({Key? key}) : super(key: key);

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
            groupValue: drawerRoute,
            onChanged: (value) {
              page = value;
              setState(() {});
            },
          ),
          Container(
            height: double.infinity,
            width: 1,
            margin: EdgeInsets.symmetric(vertical: 40.w),
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.1),
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
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}
