import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:global_repository/global_repository.dart';
import 'package:xterm/xterm.dart';
import 'term_bottom_bar.dart';

class TermareViewWithBottomBar extends StatefulWidget {
  const TermareViewWithBottomBar({
    super.key,
    required this.child,
    required this.pty,
    required this.terminal,
  });
  final Widget child;
  final Pty pty;
  final Terminal terminal;
  @override
  State createState() => _TermareViewWithBottomBarState();
}

class _TermareViewWithBottomBarState extends State<TermareViewWithBottomBar> {
  @override
  void dispose() {
    super.dispose();
  }

  SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle.light;
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiOverlayStyle,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: SafeAreaFix(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: widget.child,
                  ),
                  TerminalFoot(
                    pty: widget.pty,
                    terminal: widget.terminal,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
