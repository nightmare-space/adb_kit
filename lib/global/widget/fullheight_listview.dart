//这个Widget会默认把ListView显示到最大
import 'package:flutter/material.dart';

class FullHeightListView extends StatefulWidget {
  const FullHeightListView({Key key, this.child}) : super(key: key);
  final Widget child;

  @override
  _FullHeightListViewState createState() => _FullHeightListViewState();
}

class _FullHeightListViewState extends State<FullHeightListView> {
  final ScrollController _scrollController = ScrollController();
  double height = 32;
  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  Future<void> _onAfterRendering(Duration timeStamp) async {
    // print(maxScrollExtent);
    // print(_scrollController.position.viewportDimension +
    //     _scrollController.position.maxScrollExtent);
    // print(_scrollController.position.viewportDimension + maxScrollExtent * 2);
    height = _scrollController.position.viewportDimension +
        _scrollController.position.maxScrollExtent;
    setState(() {});
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      // print(_scrollController.position.viewportDimension);
      // print("context:${context.size.height}");
      // print("maxScrollExtent:${_scrollController.position.maxScrollExtent}");
    });
  }

  @override
  Widget build(BuildContext context) {
    // print(cont)
    return SizedBox(
      height: height,
      child: ListView(
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        children: <Widget>[
          widget.child,
        ],
      ),
    );
  }
}
