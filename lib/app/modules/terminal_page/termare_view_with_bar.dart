import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';
import 'term_bottom_bar.dart';

class TermareViewWithBottomBar extends StatefulWidget {
  const TermareViewWithBottomBar({
    Key? key,
    required this.child,
    required this.pty,
    required this.terminal,
  }) : super(key: key);
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
        body: SafeArea(
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
              // if (PlatformUtil.isDesktop())
              //   Align(
              //     alignment: Alignment.topRight,
              //     child: SizedBox(
              //       height: 32.0,
              //       child: IconButton(
              //         onPressed: () {
              //           Navigator.pop(context);
              //         },
              //         icon: const Icon(
              //           Icons.clear,
              //           color: Colors.white,
              //         ),
              //       ),
              //     ),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
