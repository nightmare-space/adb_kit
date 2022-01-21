import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/material.dart';
import 'package:termare_pty/termare_pty.dart';
import 'package:termare_view/termare_view.dart';

class TerminalPage extends StatelessWidget {
  const TerminalPage({Key key, this.enableInput = false}) : super(key: key);

  final bool enableInput;

  @override
  Widget build(BuildContext context) {
    if (configController.isDarkTheme) {
      Global().termareController.theme = TermareStyles.vsCode.copyWith(
        backgroundColor: Theme.of(context).cardColor,
      );
    } else {
      Global().termareController.theme = TermareStyles.macos.copyWith(
        backgroundColor: Theme.of(context).cardColor,
      );
    }
    return TermarePty(
      enableInput: enableInput,
      controller: Global.instance.termareController..enableCursor(),
      pseudoTerminal: Global.instance.pseudoTerminal,
    );
  }
}
