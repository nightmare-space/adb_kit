import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/controller/history_controller.dart';
import 'package:adb_tool/app/modules/online_devices/controllers/online_controller.dart';
import 'package:get/get.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DevicesController());
    Get.put(OnlineController());
    Get.put(HistoryController());
  }
}
