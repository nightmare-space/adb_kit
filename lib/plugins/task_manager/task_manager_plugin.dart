import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/plugins/task_manager/task_manager.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:flutter/material.dart';

class TaskManagerPlugin extends Pluggable {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity? device) {
    return TaskManager(entity: device);
  }

  @override
  String get displayName => S.current.taskManager;

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => S.current.taskManager;

  @override
  void onTrigger() {}
}
