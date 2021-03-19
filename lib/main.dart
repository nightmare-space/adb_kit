import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:adb_tool/drawer.dart';
import 'package:custom_log/custom_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:provider/provider.dart';
import 'app/routes/app_pages.dart';
import 'global/instance/global.dart';
import 'page/exec_cmd_page.dart';
import 'page/install/adb_insys_page.dart';
import 'page/net_debug/remote_debug_page.dart';
import 'page/search_ip_page.dart';

void main() {
  PlatformUtil.setPackageName('com.nightmare.adbtools');
  Global.instance;
  runApp(
    NiToastNew(
      child: GetMaterialApp(
        title: 'ADB TOOL',
        initialRoute: AppPages.INITIAL,
        getPages: AppPages.routes,
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
}
