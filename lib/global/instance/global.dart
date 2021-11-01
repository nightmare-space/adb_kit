import 'dart:async';
import 'dart:io';
import 'package:adb_tool/app/controller/history_controller.dart';
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
    pseudoTerminal = TerminalUtil.getShellTerminal();
    pseudoTerminal.write('clear\r');
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
  PseudoTerminal pseudoTerminal;
  TermareController termareController = TermareController(
    fontFamily: '${Config.flutterPackage}MenloforPowerline',
    theme: TermareStyles.macos.copyWith(
      backgroundColor: AppColors.background,
    ),
    enableLog: false,
  )..hideCursor();

  Future<void> _receiveBoardCast() async {
    multicast.addListener((message, address) async {
      if (message.startsWith('find')) {
        final String unique = message.replaceAll('find ', '');
        // print('message -> $message');
        if (unique != await UniqueUtil.getDevicesId()) {
          // 触发UI上的更新
          final onlineController = Get.find<OnlineController>();
          onlineController.addDevices(
            DeviceEntity(unique, address),
          );
        }
        return;
      }
    });
  }

  Future<void> _sendBoardCast() async {
    multicast.startSendBoardcast('find ${await UniqueUtil.getDevicesId()}');
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
            address,
            '5555',
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
          <String>['+x', filePath],
        );
        Log.d(
          '写入文件 $fileName 输出 stdout:${result.stdout} stderr；${result.stderr}',
        );
      }
    }
    for (final String fileName in globalFiles) {
      await Directory(RuntimeEnvir.binPath).create(recursive: true);
      final filePath = RuntimeEnvir.binPath + '/$fileName';
      await AssetsUtils.copyAssetToPath('assets/$fileName', filePath);
      final ProcessResult result = await Process.run(
        'chmod',
        <String>['+x', filePath],
      );
      Log.d(
        '写入文件 $fileName 输出 stdout:${result.stdout} stderr；${result.stderr}',
      );
    }
  }

  Future<void> initGlobal() async {
    print('initGlobal');
    if (isInit) {
      return;
    }
    isInit = true;
    installAdbToEnvir();
    _receiveBoardCast();
    _sendBoardCast();
    _initNfcModule();
    _socketServer();
  }
}
