import 'package:adb_kit/app/modules/drawer/tablet_drawer.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class TableHome extends StatefulWidget {
  const TableHome({Key? key}) : super(key: key);

  @override
  State<TableHome> createState() => _TableHomeState();
}

class _TableHomeState extends State<TableHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          TabletDrawer(
            groupValue: Global().drawerRoute,
            onChanged: (value) {
              Global().page = value;
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
              child: Global().page,
            ),
          ),
        ],
      ),
    );
  }
}
