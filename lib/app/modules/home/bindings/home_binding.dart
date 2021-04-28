import 'package:adb_tool/app/controller/history_controller.dart';
import 'package:adb_tool/app/modules/home/controllers/devices_controller.dart';
import 'package:adb_tool/app/modules/online_devices/controllers/online_controller.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
    Get.put(DevicesController());
    Get.put(OnlineController());
    Get.lazyPut(() => HistoryController());
  }
}
