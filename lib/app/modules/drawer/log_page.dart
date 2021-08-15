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
        backgroundColor: AppColors.terminalBack,
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
    return Scaffold(
      backgroundColor: controller.theme.backgroundColor,
      appBar: AppBar(
        title: const Text('日志'),
      ),
      body: SafeArea(
        child: TermareView(
          controller: controller,
        ),
      ),
    );
  }
}
