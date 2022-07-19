import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:adb_tool/app/controller/controller.dart';
import 'package:adb_tool/app/modules/home/bindings/home_binding.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/utils/unique_util.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:logger_view/logger_view.dart';
import 'package:multicast/multicast.dart';
import 'package:xterm/next/terminal.dart';
import 'dart:core' as core;
import 'dart:core';

import 'page_manager.dart';

extension PTYExt on Pty {
  void writeString(String data) {
    write(utf8.encode(data));
  }
}

class Global {
  factory Global() => _getInstance();
  Global._internal() {
    // Log.defaultLogger.printer = const Print();
    HomeBinding().dependencies();
  }

  static Global get instance => _getInstance();
  static Global _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  String drawerRoute = PageManager.instance.pages.first.runtimeType.toString();
  Widget page;
  void changeDrawerRoute(core.String route) {
    drawerRoute = route;
  }

  YanProcess process = YanProcess(
    envir: GetPlatform.isIOS
        ? {}
        : {
            'TMPDIR': RuntimeEnvir.tmpPath,
            'HOME': RuntimeEnvir.homePath,
          },
  );

  bool isInit = false;
  Multicast multicast = Multicast(
    port: adbToolUdpPort,
  );

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  // todo initial
  Pty pty;
  Terminal terminal = Terminal();
  void initTerminal() {
    Map<String, String> envir;
    envir = Map.from(Platform.environment);
    // 设置HOME变量到应用内路径会引发异常
    // envir['HOME'] = RuntimeEnvir.homePath;
    // envir['TERM'] = 'xterm-256color';
    envir['PATH'] = RuntimeEnvir.path;
    pty ??= Pty.start(
      'sh',
      arguments: ['-l'],
      environment: envir,
      workingDirectory: '/',
    );

    pty.output.cast<List<int>>().transform(const Utf8Decoder()).listen(
      (event) {
        terminal.write(event);
      },
    );
  }

  bool logTerminalIsInit = false;

  Future<void> _receiveBoardCast() async {
    multicast.addListener((message, address) async {
      if (message.startsWith('find')) {
        final String unique = message.replaceAll('find ', '');
        // print('message -> $message');
        if (unique != await UniqueUtil.getDevicesId()) {
          // 触发UI上的更新
          try {
            // try不能省
            // MaterialApp 可能还没加载
            final devicesCTL = Get.find<DevicesController>();
            if (devicesCTL.getDevicesByIp(address) == null) {
              try {
                AdbResult result = await AdbUtil.connectDevices(address);
              } on AdbException catch (e) {
                Log.e('通过UDP发现自动连接设备失败 : $e');
              }
              showToast('已自动连接$address');
            }
          } catch (e) {
            Log.e('receiveBoardCast error : $e');
          }
        }
        return;
      }
    });
  }

  Future<void> _sendBoardCast() async {
    multicast.startSendBoardcast(
      ['find ${await UniqueUtil.getDevicesId()}'],
      duration: const Duration(
        milliseconds: 300,
      ),
    );
  }

  int successBindPort = 0;
  Future<void> _socketServer() async {
    successBindPort = await getSafePort(adbToolQrPort, adbToolQrPort + 10);
    // 等待扫描二维码的连接
    HttpServerUtil.bindServer(
      successBindPort,
      (address) async {
        // 弹窗
        AdbResult result;
        try {
          result = await AdbUtil.connectDevices(
            address,
          );
          showToast(result.message);
          HistoryController.updateHistory(
            address: address,
            port: '5555',
            name: address,
          );
        } on AdbException catch (e) {
          showToast(e.message);
        }
      },
    );
  }

  static String androidPrefix = 'android';
  List<String> androidFiles = [
    '$androidPrefix/adb',
    '$androidPrefix/adb_binary',
    '$androidPrefix/adb.bin-armeabi',
    '$androidPrefix/libbrotlidec.so',
    '$androidPrefix/libbrotlienc.so',
    '$androidPrefix/libc++_shared.so',
    '$androidPrefix/liblz4.so.1',
    '$androidPrefix/libprotobuf.so',
    '$androidPrefix/libusb-1.0.so',
    '$androidPrefix/libz.so.1',
    '$androidPrefix/libzstd.so.1',
    '$androidPrefix/libbrotlicommon.so',
  ];

  List<String> globalFiles = [
    'app_server',
  ];

  /// 复制一堆执行文件
  Future<void> installAdbToEnvir() async {
    if (kIsWeb) {
      return true;
    }
    AssetsManager.copyFiles(
      localPath: '${RuntimeEnvir.binPath}/',
      android: androidFiles,
      macOS: [],
      global: globalFiles,
      package: Config.flutterPackage,
    );
  }

  //
  bool hasSafeArea = true;
  // 是否展示二维码
  bool showQRCode = true;
  Future<void> initGlobal() async {
    if (isInit) {
      return;
    }
    initTerminal();
    Log.i('Global instance init');
    if (RuntimeEnvir.packageName != Config.packageName) {
      // 如果这个项目是独立运行的，那么RuntimeEnvir.packageName会在main函数中被设置成Config.packageName
      Config.flutterPackage = 'packages/adb_tool/';
    }
    ConfigController controller = Get.put(ConfigController());
    Log.i('当前系统语言 ${window.locales}');
    Log.i('当前系统主题 ${window.platformBrightness}');
    Log.i('当前布局风格 ${controller.screenType}');
    Log.i('当前App内部主题 ${controller.theme}');
    // Log.i('当前设备Root状态 ${await YanProcess().isRoot()}');
    Log.i('是否自动连接局域网设备 ${controller.autoConnect}');
    isInit = true;
    if (controller.autoConnect) {
      _receiveBoardCast();
    }
    if (GetPlatform.isAndroid) {
      _sendBoardCast();
    }
    _socketServer();
    await installAdbToEnvir();
  }

  void initTerminalSize(Size size) {
    if (size == Size.zero) {
      return;
    }
    logTerminalIsInit = true;
    // 32 是日志界面的边距
  }
}

class Print implements Printable {
  const Print();
  @override
  void print(DateTime time, Object object) {
    final String data =
        '[${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}] $object';

    // ignore: avoid_print
    // core.print(data);
  }
}

String twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}
