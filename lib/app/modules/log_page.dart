import 'dart:ui';

import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/widget/menu_button.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    AppBar appBar;
    if (Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        title: const Text('日志'),
        systemOverlayStyle:OverlayStyle.dark,
        leading: Menubutton(
          scaffoldContext: context,
        ),
      );
    }
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.w),
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
              padding: EdgeInsets.all(8.w),
              child: TermareView(
                controller: Global().logTerminalCTL,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
