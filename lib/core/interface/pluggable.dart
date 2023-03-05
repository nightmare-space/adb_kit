import 'package:adb_tool/app/controller/controller.dart';
import 'package:flutter/widgets.dart';

// inspired by flutter_ume
abstract class Pluggable {
  String get name;
  String get displayName;
  void onTrigger();
  Widget buildWidget(BuildContext context, DevicesEntity? device);
  ImageProvider get iconImageProvider;
}
