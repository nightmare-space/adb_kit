import 'package:flutter/material.dart';

class NiCardButton extends StatefulWidget {
  const NiCardButton({
    Key key,
    this.child,
    this.onTap,
    this.blurRadius = 8.0,
    this.shadowColor = Colors.black,
    this.borderRadius = 8.0,
  }) : super(key: key);
  final Widget child;
  final Function onTap;
  final double blurRadius;
  final double borderRadius;
  final Color shadowColor;
  @override
  _NiCardButtonState createState() => _NiCardButtonState();
}

class _NiCardButtonState extends State<NiCardButton>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  bool isOnTap = false;
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        isOnTap = false;
        setState(() {});
        Feedback.forLongPress(context);
        animationController.reverse();
        if (widget.onTap != null) {
          widget.onTap();
        }
      },
      onTapDown: (_) {
        animationController.forward();
        Feedback.forLongPress(context);
        isOnTap = true;
        setState(() {});
      },
      onTapCancel: () {
        animationController.reverse();
        Feedback.forLongPress(context);
        isOnTap = false;
        setState(() {});
      },
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..scale(1.0 - animationController.value * 0.05),
        child: Container(
          margin: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.all(
              Radius.circular(widget.borderRadius),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: widget.shadowColor.withOpacity(
                  0.1 - animationController.value * 0.1,
                ),
                offset: const Offset(0.0, 0.0), //阴影xy轴偏移量
                blurRadius: widget.blurRadius, //阴影模糊程度
                spreadRadius: 0.0, //阴影扩散程度
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(widget.borderRadius),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
