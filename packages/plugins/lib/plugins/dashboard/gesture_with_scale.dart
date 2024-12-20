
import 'package:flutter/material.dart';

class GestureWithScale extends StatefulWidget {
  const GestureWithScale({
    Key? key,
    this.onTap,
    this.child,
  }) : super(key: key);
  final void Function()? onTap;
  final Widget? child;

  @override
  State createState() => _GestureWithScaleState();
}

class _GestureWithScaleState extends State<GestureWithScale> with SingleTickerProviderStateMixin {
  AnimationController? animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    animationController!.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(
          1.0 - animationController!.value * 0.02,
        ),
      child: GestureDetector(
        onTap: () {
          if (widget.onTap == null) {
            return;
          }
          setState(() {});
          Feedback.forLongPress(context);
          Feedback.forTap(context);
          animationController!.reverse();
          widget.onTap!();
        },
        onTapDown: (_) {
          if (widget.onTap == null) {
            return;
          }
          animationController!.forward();
          Feedback.forLongPress(context);
          setState(() {});
        },
        onTapCancel: () {
          if (widget.onTap == null) {
            return;
          }
          animationController!.reverse();
          Feedback.forLongPress(context);
          Feedback.forTap(context);
          setState(() {});
        },
        child: widget.child,
      ),
    );
  }
}
