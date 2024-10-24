import 'package:adb_kit/app/controller/controller.dart';
import 'package:flutter/widgets.dart';
import 'package:app_channel/app_channel.dart';

// inspired by flutter_ume
abstract class ADBKITPlugin {
  String get name;
  // plugin id, must be unique
  String get id;
  BuildContext? context;
  void onTrigger();
  Widget buildWidget(BuildContext context, DevicesEntity? device);
  ImageProvider get iconImageProvider;
  AppChannel? appChannel;
}
