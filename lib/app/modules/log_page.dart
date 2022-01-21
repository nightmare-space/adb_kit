import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/widget/menu_button.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare_view/termare_view.dart';

import 'overview/pages/overview_page.dart';

class LogPage extends StatefulWidget {
  const LogPage({Key key}) : super(key: key);

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
    if (configController.isDarkTheme) {
      Global().logTerminalCTL.theme = TermareStyles.vsCode.copyWith(
        backgroundColor: Theme.of(context).cardColor,
        fontSize: 11.w,
      );
    } else {
      Global().logTerminalCTL.theme = TermareStyles.macos.copyWith(
        backgroundColor: Theme.of(context).cardColor,
        fontSize: 11.w,
      );
    }
    AppBar appBar;
    if (Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        title: const Text('日志'),
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
          child: CardItem(
            child: TermareView(
              controller: Global().logTerminalCTL,
            ),
          ),
        ),
      ),
    );
  }
}
