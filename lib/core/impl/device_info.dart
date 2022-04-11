import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/modules/wrappers/app_manager_wrapper.dart';
import 'package:adb_tool/app/modules/wrappers/device_info_wrapper.dart';
import 'package:adb_tool/core/interface/pluggable.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/painting/image_provider.dart';

class DeviceInfoPlugin extends Pluggable {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity device) {
    return DeviceInfoWrapper(
      device: device.serial,
    );
  }

  @override
  String get displayName => '设备信息';

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => '设备信息';

  @override
  void onTrigger() {}
}
