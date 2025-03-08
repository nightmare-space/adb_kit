import 'dash_board.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:adb_interface/adb_interface.dart';
import 'package:adb_util/adb_util.dart';

/// 控制面板
/// Dashboard
/// A handle to the location of a widget in the widget tree.
///
class DashboardPlugin extends ADBKITPlugin {
  @override
  Widget buildWidget(BuildContext context, ADBDevice device) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      ),
      child: Center(
        child: Dashboard(device: device),
      ),
    );
  }

  @override
  String get name => S.current.dashboard;

  @override
  String get id => '$this';
}
