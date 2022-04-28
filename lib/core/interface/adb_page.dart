import 'package:flutter/material.dart';

abstract class ADBPage {
  /// 菜单组件
  Widget buildDrawer(BuildContext context);

  /// 在平板UI显示的菜单组件
  Widget buildTabletDrawer(BuildContext context);

  /// 菜单对应的功能页面
  Widget buildPage(BuildContext context);

  /// 是否可用
  bool get isActive;

  /// 点击事件
  void onTap();
}
