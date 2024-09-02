import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/plugins/app_manager/app_manager_wrapper.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:app_manager/controller/check_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppManagerPlugin extends Pluggable {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity? device) {
    Get.put(CheckController());
    return AppManagerWrapper(
      devicesEntity: device,
    );
  }

  @override
  String get displayName => '桌面启动';

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => S.current.appManager;

  @override
  void onTrigger() {}
}
