library adb_tool;

import 'dart:io';
import 'package:custom_log/custom_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'app/routes/app_pages.dart';
import 'global/instance/global.dart';

void main() {
  PlatformUtil.setPackageName('com.nightmare.adbtools');
  Global.instance;
  runApp(
    NiToastNew(
      child: GetMaterialApp(
        title: 'ADB TOOL',
        initialRoute: AdbPages.INITIAL,
        getPages: AdbPages.routes,
        defaultTransition: Transition.fade,
      ),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  enableUdpMulti();
}

Future<void> enableUdpMulti() async {
  if (Platform.isAndroid) {
    final MethodChannel methodChannel = const MethodChannel('multicast-lock');
    bool result = await methodChannel.invokeMethod<bool>('aquire');
    Log.d('result -> $result');
  }
}
