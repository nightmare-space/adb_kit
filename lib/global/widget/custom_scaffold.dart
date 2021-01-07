import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

// 主要动态适配桌面端与移动端的侧栏
class NiScaffold extends StatefulWidget {
  const NiScaffold({
    Key key,
    this.drawer,
    this.body,
    this.appBar,
  }) : super(key: key);
  final Widget drawer;
  final Widget body;
  final PreferredSizeWidget appBar;
  @override
  _NiScaffoldState createState() => _NiScaffoldState();
}

class _NiScaffoldState extends State<NiScaffold> {
  @override
  Widget build(BuildContext context) {
    final bool isMobile = PlatformUtil.isMobilePhone();
    return Scaffold(
      // backgroundColor: Colors.white,
      drawer: isMobile ? widget.drawer : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) widget.drawer,
          Expanded(
            child: Scaffold(
              appBar: widget.appBar,
              body: widget.body,
            ),
          ),
        ],
      ),
    );
  }
}
