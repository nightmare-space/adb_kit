library adb_tool;

import 'package:flutter/material.dart';

// import 'package:flutter_acrylic/flutter_acrylic.dart';

// 这个文件提供其他项目集成adb_tool的时候导包
export 'app/modules/history/history_page.dart';
export 'app/modules/log_page.dart';
export 'app/routes/app_pages.dart';
export 'global/instance/global.dart';
export 'main.dart';
export 'global/instance/page_manager.dart';
export 'global/instance/plugin_manager.dart';
export 'global/drawer/drawer.dart';
export 'plugins/plugin.dart';
export 'package:global_repository/global_repository.dart' show RuntimeEnvir;
export 'generated/l10n.dart';
export 'themes/theme.dart';


Future<double> getMacTitlebarWidth() async {
  return 0;
  // return await Window.getTitlebarHeight();
}


Widget? personHeader;