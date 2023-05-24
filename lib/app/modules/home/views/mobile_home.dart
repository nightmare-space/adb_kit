import 'package:adb_kit/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class MobileHome extends StatefulWidget {
  const MobileHome({Key? key}) : super(key: key);

  @override
  State<MobileHome> createState() => _MobileHomeState();
}

class _MobileHomeState extends State<MobileHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DesktopPhoneDrawer(
        width: MediaQuery.of(context).size.width * 2 / 3,
        groupValue: Global().drawerRoute,
        onChanged: (value) {
          Global().page = value;
          setState(() {});
          Navigator.pop(context);
        },
      ),
      body: PageTransitionSwitcher(
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
    );
  }
}
