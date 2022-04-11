import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/modules/wrappers/app_launcher_wrapper.dart';
import 'package:adb_tool/core/interface/pluggable.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/painting/image_provider.dart';

class AppLauncherPlugin extends Pluggable {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity device) {
    return AppLauncherWrapper(
      devicesEntity: device,
    );
  }

  @override
  String get displayName => '桌面启动';

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => '桌面启动';

  @override
  void onTrigger() {
    // TODO: implement onTrigger
  }
}
