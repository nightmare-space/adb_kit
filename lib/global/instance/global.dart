import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/controller/history_controller.dart';
import 'package:adb_tool/app/modules/home/bindings/home_binding.dart';
import 'package:adb_tool/app/modules/online_devices/controllers/online_controller.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/themes/app_colors.dart';
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

class Global {
  factory Global() => _getInstance();
  Global._internal() {
    defaultLogger.logDelegate = const Print();
    HomeBinding().dependencies();
  }

  static Global get instance => _getInstance();
  static Global _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  YanProcess process = YanProcess(
    envir: {
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

  PseudoTerminal pseudoTerminal = TerminalUtil.getShellTerminal()
    ..write('clear\r');

  TermareController termareController = TermareController(
    fontFamily: '${Config.flutterPackage}MenloforPowerline',
    theme: TermareStyles.macos.copyWith(
      backgroundColor: AppColors.background,
    ),
    enableLog: false,
  )..hideCursor();

  final TermareController logTerminalCTL = TermareController(
    enableLog: false,
    theme: TermareStyles.macos.copyWith(
      cursorColor: Colors.transparent,
      backgroundColor: AppColors.background,
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
            final onlineController = Get.find<OnlineController>();
            onlineController.updateDevices(
              DeviceEntity(unique, address),
            );
          } catch (e) {}
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

  Future<void> _initNfcModule() async {
    print('启动_initNfcModule');
    if (!kIsWeb && !Platform.isAndroid) {
      return;
    }
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
    'server.jar',
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
        await AssetsUtils.copyAssetToPath('assets/android/$fileName', filePath);
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
      await AssetsUtils.copyAssetToPath('assets/$fileName', filePath);
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
    Log.i('initGlobal');
    if (isInit) {
      return;
    }
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
    _initNfcModule();
    _socketServer();
    await installAdbToEnvir();
  }

  void initTerminalSize(Size size) {
    if (size == Size.zero) {
      return;
    }
    // 32 是日志界面的边距
    logTerminalCTL.setWindowSize(Size(size.width - 32.w, size.height));
  }
}

class Print implements Logable {
  const Print();
  @override
  void log(DateTime time, Object object) {
    final String data =
        '[${_twoDigits(time.hour)}:${_twoDigits(time.minute)}:${_twoDigits(time.second)}] $object';
    Global().logTerminalCTL.write(data + '\r\n');
    print(data);
  }
}

String _twoDigits(int n) {
  if (n >= 10) return "${n}";
  return "0${n}";
}
