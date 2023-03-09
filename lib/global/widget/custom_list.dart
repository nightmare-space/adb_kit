import 'package:flutter/material.dart';

class CustomList extends StatefulWidget {
  const CustomList({Key? key, this.child}) : super(key: key);
  final Widget? child;

  @override
  State createState() => _CustomListState();
}

class _CustomListState extends State<CustomList> {
  ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(CustomList old) {
    WidgetsBinding.instance.addPostFrameCallback(_onAfterRendering);
    super.didUpdateWidget(old);
  }

  Future<void> _onAfterRendering(Duration timeStamp) async {
    scrollController.jumpTo(scrollController.position.maxScrollExtent);
    // print('object');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: widget.child,
    );
  }
}
