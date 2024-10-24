library plugins;

import 'package:adb_kit/adb_kit.dart';
import 'package:plugins/plugins/file_manager/file_manager.dart';
export 'app_launcher.dart';
export 'plugins/app_manager/app_manager_plugin.dart';
export 'plugins/app_starter/app_starter_plugin.dart';
export 'plugins/dashboard/dash_board_plugin.dart';
export 'plugins/device_info/device_info_plugin.dart';
export 'plugins/task_manager/task_manager_plugin.dart';
export 'plugins/file_manager/file_manager.dart';
export 'plugins/process_manager/process_manager_plugin.dart';
export 'generated/l10n.dart';
export 'widget/i18n_wrapper.dart';
import 'generated/intl/messages_en.dart' as en;
import 'generated/intl/messages_zh_CN.dart' as zh_CN;
import '';

Map<String, dynamic> en_message = en.messages.messages;
Map<String, dynamic> zh_cn_messages = zh_CN.messages.messages;

void registerADBPlugin() {
  Future.delayed(const Duration(milliseconds: 1000), () {
    PluginManager.instance
      ..registerADBPlugin(DashboardPlugin())
      ..registerADBPlugin(FilePlugin())
      ..registerADBPlugin(AppStarterPlugin())
      // ..registerADBPlugin(AppManagerPlugin())
      ..registerADBPlugin(DeviceInfoPlugin())
      ..registerADBPlugin(ProcessPlugin());
    // ..registerADBPlugin(TaskManagerPlugin());
  });
}
