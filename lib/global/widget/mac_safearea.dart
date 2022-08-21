import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get/utils.dart';
import 'package:window_manager/window_manager.dart';

int titlebarHeight = 0;

class MacSafeArea extends StatefulWidget {
  const MacSafeArea({
    Key key,
    this.child,
  }) : super(key: key);
  final Widget child;

  @override
  State<MacSafeArea> createState() => _MacSafeAreaState();
}

class _MacSafeAreaState extends State<MacSafeArea> {
  Future<void> calculateTitlebarHeight() async {
    if (!Global().hasSafeArea) {
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
