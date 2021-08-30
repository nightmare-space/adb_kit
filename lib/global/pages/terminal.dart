import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/material.dart';
import 'package:termare_pty/termare_pty.dart';

class TerminalPage extends StatelessWidget {
  const TerminalPage({Key key, this.enableInput = false}) : super(key: key);

  final bool enableInput;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: TermarePty(
        enableInput: enableInput,
        controller: Global.instance.termareController..enableCursor(),
        pseudoTerminal: Global.instance.pseudoTerminal,
      ),
    );
  }
}
