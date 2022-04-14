import 'package:flutter/material.dart';

abstract class ADBPage{
  Widget buildDrawer(BuildContext context);
  Widget buildPage(BuildContext context);
  bool get isActive;
  void  onTap();
}