import 'dart:io';
import 'dart:ui';
import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/controller/history_controller.dart';
import 'package:adb_tool/app/modules/home/bindings/home_binding.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/utils/unique_util.dart';
import 'package:adbutil/adbutil.dart';
import 'package:dart_pty/dart_pty.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:multicast/multicast.dart';
import 'package:pseudo_terminal_utils/pseudo_terminal_utils.dart';
import 'package:termare_view/termare_view.dart';
import 'dart:core' as core;
import 'dart:core';

class Global {
  factory Global() => _getInstance();
  Global._internal() {
    Log.defaultLogger.printer = const Print();
    HomeBinding().dependencies();
  }

  static Global get instance => _getInstance();
  static Global _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  YanProcess process = YanProcess(
    envir: GetPlatform.isIOS
        ? {}
        : {
            'TMPDIR': RuntimeEnvir.tmpPath,
            'HOME': RuntimeEnvir.homePath,
          },
  );

  bool lockAdb = false;
  bool isInit = false;
  Multicast multicast = Multicast(
    port: adbToolUdpPort,
  );

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  // todo initial
  PseudoTerminal pseudoTerminal;
  void initTerminal() {
    pseudoTerminal ??= TerminalUtil.getShellTerminal();
  }

  TermareController termareController = TermareController(
    fontFamily: '${Config.flutterPackage}MenloforPowerline',
    theme: TermareStyles.macos.copyWith(
      backgroundColor: Colors.white,
    ),
    enableLog: false,
  )..hideCursor();
  bool logTerminalIsInit = false;
  static TermareController logTerminalCTL = TermareController(
    enableLog: false,
    theme: TermareStyles.macos.copyWith(
      cursorColor: Colors.transparent,
      backgroundColor: Colors.white,
      fontSize: 10,
    ),
  )..hideCursor();

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
                AdbUtil.connectDevices(address);
              } catch (e) {
                Log.e('通过UDP发现自动连接设备失败 : $e');
              }
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
      'find ${await UniqueUtil.getDevicesId()}',
      duration: const Duration(
        milliseconds: 300,
      ),
    );
  }

  Future<void> _socketServer() async {
    // 等待扫描二维码的连接
    HttpServerUtil.bindServer(
      adbToolQrPort,
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

  List<String> androidFiles = [
    'adb',
    'adb_binary',
    'libbrotlidec.so',
    'libbrotlienc.so',
    'libc++_shared.so',
    'liblz4.so.1',
    'libprotobuf.so',
    'libusb-1.0.so',
    'libz.so.1',
    'libzstd.so.1',
    'libbrotlicommon.so',
  ];

  List<String> globalFiles = [
    'app_server',
  ];

  /// 复制一堆执行文件
  Future<void> installAdbToEnvir() async {
    if (kIsWeb) {
      return true;
    }
    if (Platform.isAndroid) {
      await Directory(RuntimeEnvir.binPath).create(recursive: true);
      for (final String fileName in androidFiles) {
        final filePath = RuntimeEnvir.binPath + '/$fileName';
        await AssetsUtils.copyAssetToPath(
          '${Config.flutterPackage}assets/android/$fileName',
          filePath,
        );
        final ProcessResult result = await Process.run(
          'chmod',
          ['+x', filePath],
        );
        Log.d(
          '更改 $fileName 权限为0755 stdout:${result.stdout} stderr；${result.stderr}',
        );
      }
    }
    for (final String fileName in globalFiles) {
      await Directory(RuntimeEnvir.binPath).create(recursive: true);
      final filePath = RuntimeEnvir.binPath + '/$fileName';
      await AssetsUtils.copyAssetToPath(
        '${Config.flutterPackage}assets/$fileName',
        filePath,
      );
      final ProcessResult result = await Process.run(
        'chmod',
        ['+x', filePath],
      );
      Log.d(
        '更改 $fileName 权限为0755 stdout:${result.stdout} stderr；${result.stderr}',
      );
    }
  }

  Future<void> initGlobal() async {
    Log.i('Global instance init');
    if (isInit) {
      return;
    }
    ConfigController controller = Get.find();
    Log.i('当前系统语言 ${window.locales}');
    Log.i('当前系统主题 ${window.platformBrightness}');
    Log.i('当前布局风格 ${controller.screenType}');
    Log.i('当前App内部主题 ${controller.theme}');
    Log.i('当前设备Root状态 ${await YanProcess().isRoot()}');
    isInit = true;
    // 等待 MaterialApp 加载完成，正确获取到屏幕大小
    // 不然logTerminalCTL不能正常的换行
    await Future.delayed(const Duration(milliseconds: 200));
    // final double screenWidth = size.width / window.devicePixelRatio;
    // final double screenHeight = size.height / window.devicePixelRatio;
    // logTerminalCTL.setWindowSize(
    //   Size(screenWidth, screenHeight),
    // );
    _receiveBoardCast();
    _sendBoardCast();
    _socketServer();
    await installAdbToEnvir();
  }

  void initTerminalSize(Size size) {
    if (size == Size.zero) {
      return;
    }
    logTerminalIsInit = true;
    // 32 是日志界面的边距
    logTerminalCTL.setWindowSize(Size(size.width - 48.w, size.height));
  }
}

class Print implements Printable {
  const Print();
  @override
  void print(DateTime time, Object object) {
    final String data =
        '[${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}] $object';

    Global.logTerminalCTL.write(data + '\r\n');

    // ignore: avoid_print
    core.print(data);
  }
}

String twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}
