import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/app/modules/wrappers/app_manager_wrapper.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:app_manager/app_manager.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppManagerPlugin extends Pluggable {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity? device) {
    Get.put(CheckController());
    Get.put(IconController());
    return AppManagerWrapper(
      devicesEntity: device,
    );
  }

  @override
  String get displayName => '桌面启动';

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => '应用管理';

  @override
  void onTrigger() {}
}
