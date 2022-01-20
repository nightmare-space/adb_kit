import 'dart:convert';

import 'package:adb_tool/app/model/adb_historys.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConfigController extends GetxController {
  ConfigController() {}
  Color primaryColor = AppColors.accent;

  bool showPerformanceOverlay = false;
  void showPerformanceOverlayChange(bool value) {
    showPerformanceOverlay = value;
    update();
  }

  bool showSemanticsDebugger = false;
  void showSemanticsDebuggerChange(bool value) {
    showSemanticsDebugger = value;
    update();
  }

  bool debugShowMaterialGrid = false;
  void debugShowMaterialGridChange(bool value) {
    debugShowMaterialGrid = value;
    update();
  }

  bool checkerboardRasterCacheImages = false;
  void checkerboardRasterCacheImagesChange(bool value) {
    checkerboardRasterCacheImages = value;
    update();
  }
}
