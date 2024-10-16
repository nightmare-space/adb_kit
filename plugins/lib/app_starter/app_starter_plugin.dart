import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:flutter/material.dart';

import 'app_starter_page.dart';

class AppStarterPlugin extends Pluggable {
  @override
  Widget buildWidget(BuildContext context, DevicesEntity? device) {
    return AppStarterPage(
      entity: device,
    );
  }

  @override
  String get displayName => S.current.commonServiceStartup;

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => S.current.commonServiceStartup;

  @override
  void onTrigger() {}
}
