library adb_tool;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:signale/signale.dart';

import 'app/routes/app_pages.dart';
import 'config/config.dart';
import 'global/instance/global.dart';
import 'utils/assets_utils.dart';

void main() {
  RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  Global.instance;
  runApp(ToastApp(
    child: GetMaterialApp(
      enableLog: false,
      title: 'ADB TOOL',
      initialRoute: AdbPages.INITIAL,
      getPages: AdbPages.routes,
      defaultTransition: Transition.fade,
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
}

Future<void> installRes() async {
  if (kIsWeb) {
    return;
  }
  final filePath = RuntimeEnvir.binPath + '/app-release.apk';
  final Directory dir = Directory(RuntimeEnvir.binPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  AssetsUtils.copyAssetToPath('assets/app-release.apk', filePath);
  final ProcessResult result = await Process.run(
    'chmod',
    <String>['+x', filePath],
  );
  Log.d(
    '写入文件 release 输出 stdout:${result.stdout} stderr；${result.stderr}',
  );
  // print(await exec('scrcpy'));
}
