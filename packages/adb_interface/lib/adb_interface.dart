import 'package:flutter/material.dart';
import 'package:adb_util/adb_util.dart';

abstract class ADBKITPlugin {
  String get name;
  // plugin id, must be unique
  String get id;
  Widget buildWidget(BuildContext context, ADBDevice device);
}
