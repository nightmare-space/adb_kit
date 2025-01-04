// ignore_for_file: non_constant_identifier_names

library adb_tool;

// other repo can import this file

import 'package:flutter/material.dart';
import 'generated/intl/messages_en.dart' as en;
import 'generated/intl/messages_zh_CN.dart' as zh_cn;
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
export 'app/modules/overview/pages/qrcode_container.dart';

Future<double> getMacTitlebarWidth() async {
  return 0;
  // return await Window.getTitlebarHeight();
}

Widget? personHeader;

Map<String, dynamic> en_message = en.messages.messages;
Map<String, dynamic> zh_cn_messages = zh_cn.messages.messages;
