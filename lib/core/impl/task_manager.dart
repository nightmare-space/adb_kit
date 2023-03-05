import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/modules/developer_tool/task_manager.dart';
import 'package:adb_tool/core/interface/pluggable.dart';
import 'package:flutter/material.dart';

class TaskManagerPlugin extends Pluggable {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity? device) {
    return TaskManager(
      entity: device,
    );
  }

  @override
  String get displayName => '任务管理';

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => '任务管理';

  @override
  void onTrigger() {}
}
