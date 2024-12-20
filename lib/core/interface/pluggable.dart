import 'package:adb_kit/app/controller/controller.dart';
import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:flutter/widgets.dart';

// inspired by flutter_ume
abstract class ADBKITPlugin {
  String get name;
  // plugin id, must be unique
  String get id;
  BuildContext? context;
  void onTrigger();
  Widget buildWidget(BuildContext context, DevicesEntity? device);
  ImageProvider get iconImageProvider;
  AASClient? aas;
}
