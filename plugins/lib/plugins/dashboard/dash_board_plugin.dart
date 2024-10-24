import 'package:adb_kit/app/controller/devices_controller.dart';
import 'dash_board.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:flutter/material.dart';

/// 控制面板
/// Dashboard
/// A handle to the location of a widget in the widget tree.
///
class DashboardPlugin extends ADBKITPlugin {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity? device) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      child: Center(
        child: Dashboard(serial: device!.serial),
      ),
    );
  }

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => S.current.dashboard;

  @override
  void onTrigger() {}
  @override
  String get id => '$this';
}
