import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/modules/developer_tool/app_starter.dart';
import 'package:adb_tool/app/modules/developer_tool/dash_board.dart';
import 'package:adb_tool/app/modules/wrappers/app_manager_wrapper.dart';
import 'package:adb_tool/core/interface/pluggable.dart';
import 'package:flutter/material.dart';

class DashboardPlugin extends Pluggable {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity device) {
    return Dashboard(
      entity: device,
    );
  }

  @override
  String get displayName => '控制面板';

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => '控制面板';

  @override
  void onTrigger() {}
}
