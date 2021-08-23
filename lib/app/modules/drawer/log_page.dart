import 'dart:ui';

import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare_view/termare_view.dart';

class LogPage extends StatefulWidget {
  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TermareController controller = TermareController(
      enableLog: false,
      theme: TermareStyles.macos.copyWith(
        cursorColor: Colors.transparent,
        backgroundColor: AppColors.background,
      ),
    );
    final Size size = window.physicalSize;
    final double screenWidth = size.width / window.devicePixelRatio;
    final double screenHeight = size.height / window.devicePixelRatio;
    controller.setWindowSize(
      Size(screenWidth, screenHeight),
    );
    for (String line in Log.buffer.toString().split('\n')) {
      controller.write(line + '\r\n');
    }
    AppBar appBar;
    if (Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        brightness: Brightness.light,
        title: const Text('日志'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      );
    }
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12.w),
              border: Border.all(
                color: Colors.black.withOpacity(0.1),
                width: 1.w,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TermareView(
                controller: controller,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
