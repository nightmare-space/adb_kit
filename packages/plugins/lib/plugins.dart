// ignore_for_file: non_constant_identifier_names

export 'app_launcher.dart';
export 'plugins/dashboard/dash_board_plugin.dart';
export 'plugins/file_manager/file_manager.dart';
export 'generated/l10n.dart';
export 'widget/i18n_wrapper.dart';
import 'package:adb_kit/adb_kit.dart';
import 'package:android_tool/android_tool.dart';
import 'generated/intl/messages_en.dart' as en;
import 'generated/intl/messages_zh_CN.dart' as zh_cn;
import 'plugins.dart';

Map<String, dynamic> en_message = en.messages.messages;
Map<String, dynamic> zh_cn_messages = zh_cn.messages.messages;

void registerADBPlugin() {
  Future.delayed(const Duration(milliseconds: 1000), () {
    PluginManager.instance
      ..registerADBPlugin(DashboardPlugin())
      ..registerADBPlugin(FilePlugin())
      ..registerADBPlugin(AppStarterPlugin())
      ..registerADBPlugin(AppManagerPlugin())
      ..registerADBPlugin(DeviceInfoPlugin())
      ..registerADBPlugin(ProcessPlugin())
      ..registerADBPlugin(TaskManagerPlugin());
  });
}
