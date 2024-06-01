
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:xterm/xterm.dart';

class TerminalFoot extends StatefulWidget {
  const TerminalFoot({Key? key, required this.pty, required this.terminal}) : super(key: key);
  final Pty pty;
  final Terminal terminal;

  @override
  State createState() => _TerminalFootState();
}

class _TerminalFootState extends State<TerminalFoot> with SingleTickerProviderStateMixin {
  Color defaultDragColor = Colors.black.withOpacity(0.4);
  late Animation<double> height;
  late AnimationController controller;
  late Color dragColor;
  @override
  void initState() {
    super.initState();
    dragColor = defaultDragColor;
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );
    height = Tween<double>(begin: 18.0, end: 82).animate(CurvedAnimation(
      curve: Curves.easeIn,
      parent: controller,
    ));
    height.addListener(() {
      setState(() {});
    });
    controller.forward();
    // widget.terminal.keyInput(key)
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 414.w,
      height: height.value,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanDown: (_) {
                dragColor = Colors.white.withOpacity(0.8);
                setState(() {});
              },
              onPanCancel: () {
                dragColor = defaultDragColor;
                setState(() {});
              },
              onPanEnd: (_) {
                dragColor = defaultDragColor;
                setState(() {});
              },
              onTap: () {
                if (controller.isCompleted) {
                  controller.reverse();
                } else {
                  controller.forward();
                }
              },
              child: SizedBox(
                height: 16,
                child: Center(
                  child: Container(
                    width: 100,
                    height: 4,
                    decoration: BoxDecoration(
                      color: dragColor,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: 'ESC',
                    onTap: () {
                      // widget.pty.input?.call(
                      //   utf8.decode([0x1b]),
                      // );
                    },
                  ),
                ),
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: 'TAB',
                    onTap: () {
                      widget.terminal.keyInput(TerminalKey.tab);
                    },
                  ),
                ),
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: 'CTRL',
                    enable: false,
                    onTap: () {
                      // widget.pty.enbaleOrDisableCtrl();
                      // setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: 'ALT',
                  ),
                ),
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: '－',
                    onTap: () {
                      // widget.terminal.keyInput(TerminalKey.tab);
                      // widget.pty.input?.call(
                      //   utf8.decode([110 - 96]),
                      // );
                    },
                  ),
                ),
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: '↑',
                    onTap: () {
                      widget.terminal.keyInput(TerminalKey.arrowUp);
                      // widget.pty.input?.call(
                      //   utf8.decode([112 - 96]),
                      // );
                    },
                  ),
                ),
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: '↲',
                    onTap: () {
                      widget.terminal.keyInput(TerminalKey.enter);
                      // widget.pty.input?.call(
                      //   utf8.decode([110 - 96]),
                      // );
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: 'INS',
                    onTap: () {
                      // widget.pty.input?.call(
                      //   utf8.decode([0x1b]),
                      // );
                    },
                  ),
                ),
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: 'END',
                    onTap: () {
                      // widget.pty.input?.call(
                      //   utf8.decode([9]),
                      // );
                    },
                  ),
                ),
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: 'SHIFT',
                    onTap: () {
                      // widget.pty.enbaleOrDisableCtrl();
                      // setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: ':',
                  ),
                ),
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: '←',
                    onTap: () {
                      widget.terminal.keyInput(TerminalKey.arrowLeft);
                      // widget.pty.input?.call(
                      //   utf8.decode([112 - 96]),
                      // );
                    },
                  ),
                ),
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: '↓',
                    onTap: () {
                      widget.terminal.keyInput(TerminalKey.arrowDown);
                      // widget.pty.input?.call(
                      //   utf8.decode([110 - 96]),
                      // );
                    },
                  ),
                ),
                Expanded(
                  child: BottomItem(
                    pty: widget.pty,
                    title: '→',
                    onTap: () {
                      widget.terminal.keyInput(TerminalKey.arrowRight);
                      // widget.pty.input?.call(
                      //   utf8.decode([110 - 96]),
                      // );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BottomItem extends StatefulWidget {
  const BottomItem({
    Key? key,
    required this.pty,
    required this.title,
    this.onTap,
    this.enable = false,
  }) : super(key: key);
  final Pty pty;
  final String title;
  final void Function()? onTap;
  final bool enable;

  @override
  State createState() => _BottomItemState();
}

class _BottomItemState extends State<BottomItem> {
  Color backgroundColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // onTap: widget.onTap,
      onPanDown: (_) {
        widget.onTap?.call();
        backgroundColor = Colors.white.withOpacity(0.2);
        setState(() {});
        Feedback.forLongPress(context);
      },
      onPanEnd: (_) {
        backgroundColor = Colors.transparent;
        setState(() {});
        Feedback.forLongPress(context);
      },
      onPanCancel: () {
        backgroundColor = Colors.transparent;
        setState(() {});
        Feedback.forLongPress(context);
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.enable ? Colors.white.withOpacity(0.4) : backgroundColor,
        ),
        height: 30,
        child: Center(
          child: Text(
            widget.title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
