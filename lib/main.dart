library adb_tool;

import 'dart:async';
import 'dart:ui';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:plugins/plugins.dart' as plugins;
import 'generated/l10n.dart';
import 'material_entrypoint.dart';
import 'config/config.dart';
import 'package:adb_kit_extension/adb_kit_extension.dart';
import 'generated/intl/messages_en.dart' as messages_en;
import 'generated/intl/messages_zh_CN.dart' as messages_zh_cn;

Future<void> main() async {
  // 初始化运行时环境
  plugins.registerADBPlugin();
  runADBClient();
}

Future<void> runADBClient() async {
  // hook getx log
  Get.config(
    enableLog: false,
    logWriterCallback: (text, {bool? isError}) {
      Log.d(text, tag: 'GetX');
    },
  );
  // 启动文件管理器服务，以供 ADB KIT 选择本机文件
  Server.start();
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      initPersonal();
      if (!GetPlatform.isIOS) {
        final dir = (await getApplicationSupportDirectory()).path;
        Log.d('ApplicationSupportDirectory: $dir');
        RuntimeEnvir.initEnvirWithPackageName(
          Config.packageName,
          appSupportDirectory: dir,
        );
      }
      await initSetting();
      runApp(const MaterialAppWrapper());
      mergeI18n();
    },
    (error, stackTrace) {
      Log.e('${S.current.uncaughtDE} -> $error \n$stackTrace');
    },
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        parent.print(zone, line);
        // Log.d(line);
      },
    ),
  );
  DartPluginRegistrant.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Log.e('${S.current.uncaughtUE} -> ${details.exception}');
  };
  StatusBarUtil.transparent();
}

void mergeI18n() {
  messages_en.messages.messages.addAll(enMessage);
  messages_zh_cn.messages.messages.addAll(zhCNMessage);
  messages_en.messages.messages.addAll(plugins.en_message);
  messages_zh_cn.messages.messages.addAll(plugins.zh_cn_messages);
}
