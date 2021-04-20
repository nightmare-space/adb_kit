import 'package:adb_tool/global/instance/global.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:termare_pty/termare_pty.dart';
import 'package:termare_view/termare_view.dart';

class TerminalPage extends StatelessWidget {
  const TerminalPage({Key key, this.enableInput = false}) : super(key: key);

  final bool enableInput;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(Dimens.gap_dp8),
      child: Material(
        color: const Color(0xFFF0F0F0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: TermarePty(
            enableInput: enableInput,
            controller: TermareController(
              fontFamily: 'MenloforPowerline',
              theme: TermareStyles.macos.copyWith(
                backgroundColor: const Color(0xFFF0F0F0),
                defaultFontColor: Colors.black,
              ),
            )..hideCursor(),
            pseudoTerminal: Global.instance.pseudoTerminal,
          ),
        ),
      ),
    );
  }
}
