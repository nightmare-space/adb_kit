import 'package:flutter/material.dart';

class MaterialClipRRect extends StatefulWidget {
  const MaterialClipRRect({Key key, this.child, this.onTap}) : super(key: key);
  final Widget child;
  final Function onTap;
  @override
  _MaterialClipRRectState createState() => _MaterialClipRRectState();
}

class _MaterialClipRRectState extends State<MaterialClipRRect> {
  bool isOnTap = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
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
              Radius.circular(8),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0.0, 0.0), //阴影xy轴偏移量
                blurRadius: 8.0, //阴影模糊程度
                spreadRadius: 0.0, //阴影扩散程度
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(
              Radius.circular(12),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
