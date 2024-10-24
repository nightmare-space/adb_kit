import 'package:adb_kit/app/controller/devices_controller.dart';
import 'task_manager.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:flutter/material.dart';

class TaskManagerPlugin extends ADBKITPlugin {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity? device) {
    return TaskManager(entity: device);
  }

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => S.current.taskManager;

  @override
  void onTrigger() {}
  @override
  String get id => '$this';
}
