import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/modules/wrappers/app_manager_wrapper.dart';
import 'package:adb_tool/core/interface/pluggable.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/painting/image_provider.dart';

class AppManagerPlugin extends Pluggable {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity device) {
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
