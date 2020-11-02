import 'package:adb_tool/config/dimens.dart';
import 'package:flutter/material.dart';

class NiCard extends StatefulWidget {
  const NiCard({
    Key key,
    this.child,
    this.onTap,
    this.blurRadius = 8.0,
  }) : super(key: key);
  final Widget child;
  final Function onTap;
  final double blurRadius;
  @override
  _NiCardState createState() => _NiCardState();
}

class _NiCardState extends State<NiCard> {
  bool isOnTap = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        isOnTap = false;
        setState(() {});
        if (widget.onTap != null) {
          widget.onTap();
        }
      },
      onTapDown: (_) {
        isOnTap = true;
        setState(() {});
      },
      onTapCancel: () {
        isOnTap = false;
        setState(() {});
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.all(
            Radius.circular(Dimens.gap_dp12),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0.0, 0.0), //阴影xy轴偏移量
              blurRadius: widget.blurRadius, //阴影模糊程度
              spreadRadius: 0.0, //阴影扩散程度
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(
            Radius.circular(Dimens.gap_dp12),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
