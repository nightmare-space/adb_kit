import 'package:adb_kit/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class DesktopHome extends StatefulWidget {
  const DesktopHome({Key? key}) : super(key: key);

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
            groupValue: Global().drawerRoute,
            onChanged: (value) {
              Global().page = value;
              setState(() {});
            },
          ),
          Container(
            height: double.infinity,
            width: 0.5,
            margin: EdgeInsets.symmetric(vertical: 40.w),
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.4),
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
