import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/app/modules/developer_tool/app_starter.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:flutter/material.dart';

class AppStarterPlugin extends Pluggable {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity? device) {
    return AppStarter(
      entity: device,
    );
  }

  @override
  String get displayName => '常用服务启动';

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => '常用服务启动';

  @override
  void onTrigger() {}
}
