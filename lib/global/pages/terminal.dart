import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/widget/xterm_wrapper.dart';
import 'package:flutter/material.dart';

class TerminalPage extends StatelessWidget {
  const TerminalPage({Key? key, this.enableInput = false}) : super(key: key);

  final bool enableInput;

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
    } else {}
    return XTermWrapper(
      pseudoTerminal: Global().pty,
      terminal: Global().terminal,
    );
  }
}
