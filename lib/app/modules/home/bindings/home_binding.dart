import 'package:adb_tool/app/modules/online_devices/controllers/online_controller.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.put<OnlineController>(OnlineController());
  }
}
