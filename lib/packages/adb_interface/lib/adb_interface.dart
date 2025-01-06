import 'package:adb_util/adb_util.dart';
import 'package:flutter/material.dart';

abstract class ADBKITPlugin {
  String get name;
  // plugin id, must be unique
  String get id;
  Widget buildWidget(BuildContext context, ADBDevice device);
}
