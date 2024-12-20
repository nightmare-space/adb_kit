library adb_tool;

// other repo can import this file

import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'generated/intl/messages_en.dart' as en;
import 'generated/intl/messages_zh_CN.dart' as zh_CN;
import 'package:adb_util/adb_util.dart' as au;

export 'app/modules/history/history_page.dart';
export 'app/modules/log_page.dart';
export 'app/routes/app_pages.dart';
export 'global/instance/global.dart';
export 'main.dart';
export 'global/instance/plugin_manager.dart';
export 'package:global_repository/global_repository.dart' show RuntimeEnvir;
export 'generated/intl.dart';
export 'global/instance/adb_installer.dart';
export 'app/controller/controller.dart';

Future<double> getMacTitlebarWidth() async {
  return 0;
  // return await Window.getTitlebarHeight();
}

Widget? personHeader;

Map<String, dynamic> en_message = en.messages.messages;
Map<String, dynamic> zh_cn_messages = zh_CN.messages.messages;

// exec with password
Future<String> execWithPassword(String cmd) async {
  ConfigController configController = Get.find();
  return au.exec(cmd, password: configController.password);
}

// exec with password
Future<String> execWLexecWithPassword(List<String> args) async {
  ConfigController configController = Get.find();
  return au.execWL(args, password: configController.password);
}
