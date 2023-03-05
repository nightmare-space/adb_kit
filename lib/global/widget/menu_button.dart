import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class Menubutton extends StatelessWidget {
  const Menubutton({Key? key, this.scaffoldContext}) : super(key: key);
  final BuildContext? scaffoldContext;

  @override
  Widget build(BuildContext context) {
    return NiIconButton(
      child: Icon(
        Icons.menu,
        size: 24.w,
      ),
      onTap: () {
        Scaffold.of(scaffoldContext!).openDrawer();
      },
    );
  }
}
