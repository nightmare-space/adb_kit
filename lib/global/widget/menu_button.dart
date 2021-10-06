import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class Menubutton extends StatelessWidget {
  const Menubutton({Key key, this.scaffoldContext}) : super(key: key);
  final BuildContext scaffoldContext;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: NiIconButton(
        child: const Icon(Icons.menu),
        onTap: () {
          Scaffold.of(scaffoldContext).openDrawer();
        },
      ),
    );
  }
}
