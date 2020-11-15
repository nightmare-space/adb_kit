import 'package:adb_tool/global/provider/process_info.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class Global {
  factory Global() => _getInstance();
  Global._internal() {
    environment = PlatformUtil.environment();
    themeFollowSystem = true;
  }
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  // 由于使用的是页面级别的Provider，所以push后的context会找不到Provider的祖先节点
  ProcessState processState;
  Map<String, String> environment;
  bool themeFollowSystem;
  String _documentsDir;
  static Global get instance => _getInstance();
  static Global _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  Future<void> initGlobal() async {}

  static String get documentsDir => instance._documentsDir;
}
