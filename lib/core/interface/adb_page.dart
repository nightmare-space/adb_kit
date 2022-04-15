import 'package:flutter/material.dart';

abstract class ADBPage {
  Widget buildDrawer(BuildContext context, void Function() onTap);
  Widget buildTabletDrawer(BuildContext context, void Function() onTap);
  Widget buildPage(BuildContext context);
  bool get isActive;
  void onTap();
}
