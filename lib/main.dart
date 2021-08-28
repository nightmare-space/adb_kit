library adb_tool;

import 'dart:io';
import 'package:app_manager/app_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:signale/signale.dart';

import 'app/routes/app_pages.dart';
import 'config/config.dart';
import 'global/instance/global.dart';
import 'utils/assets_utils.dart';

void main() {
  // 初始化运行时环境
  RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  // 初始化终端等
  Global.instance;
  runApp(ToastApp(
    child: GetMaterialApp(
      enableLog: false,
      title: 'ADB TOOL',
      initialRoute: AdbPages.INITIAL,
      getPages: AdbPages.routes + AppPages.routes,
      defaultTransition: Transition.fadeIn,
      debugShowCheckedModeBanner: false,
    ),
  ));
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  installRes();
  // DateTime();
}

/// 安装资源
Future<void> installRes() async {
  if (kIsWeb) {
    return;
  }
  final filePath = RuntimeEnvir.binPath + '/server.jar';
  final Directory dir = Directory(RuntimeEnvir.binPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  AssetsUtils.copyAssetToPath('assets/server.jar', filePath);
  final ProcessResult result = await Process.run(
    'chmod',
    <String>['+x', filePath],
  );
  Log.d(
    '更改 server.jar 权限输出 stdout:${result.stdout} stderr；${result.stderr}',
  );
  // print(await exec('scrcpy'));
}
