import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/app/controller/history_controller.dart';
import 'package:adb_kit/config/config.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // TODO(lin): 测试这 Bindings 还用不用
    if (RuntimeEnvir.packageName == Config.packageName) {
      Get.put(DevicesController());
    }
    Get.put(HistoryController());
    Get.put(ConfigController());
  }
}
