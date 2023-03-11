import 'package:adb_kit/global/instance/global.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get/utils.dart';
import 'package:window_manager/window_manager.dart';

int titlebarHeight = 0;

class DesktopSafeArea extends StatefulWidget {
  const DesktopSafeArea({
    Key? key,
    this.child,
  }) : super(key: key);
  final Widget? child;

  @override
  State<DesktopSafeArea> createState() => _DesktopSafeAreaState();
}

class _DesktopSafeAreaState extends State<DesktopSafeArea> {
  Future<void> calculateTitlebarHeight() async {
    if (!Global().hasSafeArea || GetPlatform.isMobile) {
      return;
    }
    titlebarHeight = 24;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    calculateTitlebarHeight();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: titlebarHeight.toDouble()),
      child: widget.child,
    );
  }
}
