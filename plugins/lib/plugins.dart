library plugins;

import 'package:adb_kit/adb_kit.dart';
import 'package:plugins/file_manager/fm_plugin.dart';
export 'app_launcher.dart';
export 'app_manager/app_manager_plugin.dart';
export 'app_starter/app_starter_plugin.dart';
export 'dashboard/dash_board_plugin.dart';
export 'device_info/device_info_plugin.dart';
export 'task_manager/task_manager_plugin.dart';
export 'process_manager/process_manager_plugin.dart';
import '';

/// A Calculator.
class Calculator {
  /// Returns [value] plus 1.
  int addOne(int value) => value + 1;
}

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
