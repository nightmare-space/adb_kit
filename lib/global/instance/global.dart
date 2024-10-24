import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:adb_kit/app/controller/controller.dart';
import 'package:adb_kit/app/modules/home/bindings/home_binding.dart';
import 'package:adb_kit/config/config.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit_extension/adb_kit_extension.dart';
import 'package:adb_library/adb_library.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:multicast/multicast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xterm/xterm.dart';
import 'dart:core' as core;
import 'dart:core';
import 'adb_installer.dart';

extension PTYExt on Pty {
  void writeString(String data) {
    write(utf8.encode(data));
  }
}

class BoundedQueue<T> {
  final int maxSize;
  final Queue<T> _queue;

  BoundedQueue(this.maxSize) : _queue = Queue<T>();

  void add(T element) {
    if (_queue.length == maxSize) {
      _queue.removeFirst();
    }
    _queue.addLast(element);
  }

  List<T> toList() {
    return _queue.toList();
  }

  @override
  String toString() {
    return _queue.toString();
  }
}

class Global {
  factory Global() => _getInstance();
  Global._internal() {
    // Log.defaultLogger.printer = const Print();
    Directory(RuntimeEnvir.binPath).createSync(recursive: true);
    HomeBinding().dependencies();
  }

  static Global get instance => _getInstance();
  static Global? _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance!;
  }

  Terminal otgTerminal = Terminal();

  bool isInit = false;
  Multicast multicast = Multicast(
    port: adbToolUdpPort,
  );

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  Pty? pty;
  Terminal terminal = Terminal(maxLines: 10000);
  core.Future<void> initTerminal() async {
    Map<String, String> envir = RuntimeEnvir.envir();
    if (GetPlatform.isMobile) {}
    if (GetPlatform.isAndroid) {
      String? libPath = await AdbLibrary.getLibPath();
      RuntimeEnvir.put("PATH", '$libPath:${RuntimeEnvir.path}');
      // PC 设置HOME变量到应用内路径会引发异常
      // 例如 neofetch命令
      envir['HOME'] = RuntimeEnvir.binPath;
      envir['LD_LIBRARY_PATH'] = '${RuntimeEnvir.binPath}:/system/lib64';
      Directory? extenalStorage = await getExternalStorageDirectory();
      // some time we need read adb log file
      envir['TMPDIR'] = '${extenalStorage?.path}';
      envir['RUST_LOG'] = 'trace';
    }
    envir['TERM'] = 'xterm-256color';
    String shell = 'sh';
    if (GetPlatform.isWindows) {
      shell = 'cmd';
    }
    if (Platform.environment.containsKey('SHELL')) {
      shell = Platform.environment['SHELL']!;
    }
    // ! 直接由 pty start bash，在android上首次启动会crash
    // ! 原因未知
    pty ??= Pty.start(
      shell,
      arguments: [],
      environment: envir,
      workingDirectory: GetPlatform.isMobile ? RuntimeEnvir.binPath : "~",
    );
    // some device need input password
    pty!.output.cast<List<int>>().transform(const Utf8Decoder()).listen(
      (event) {
        if (event.contains('please input verify password')) {
          ConfigController controller = Get.find();
          pty!.writeString('${controller.password}\n');
        }
        terminal.write(event);
      },
    );
  }

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
                await AdbUtil.connectDevices(address);
              } on ADBException catch (e) {
                Log.e('${S.current.udpCF} -> $e');
              }
              showToast('${S.current.ac} $address');
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

  int? successBindPort = 0;
  Future<void> _socketServer() async {
    successBindPort = await getSafePort(adbToolQrPort, adbToolQrPort + 10);
    // 等待扫描二维码的连接
    HttpServerUtil.bindServer(
      successBindPort!,
      (address) async {
        // 弹窗
        AdbResult result;
        try {
          result = await AdbUtil.connectDevices(address);
          showToast(result.message);
        } on ADBException catch (e) {
          showToast(e.message!);
        }
      },
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
    // ignore: deprecated_member_use
    FlutterView flutterView = window;
    PlatformDispatcher platformDispatcher = flutterView.platformDispatcher;
    Log.i('Current Lang ${platformDispatcher.locales}');
    Log.i('Current Platform Bri ${platformDispatcher.platformBrightness}');
    Log.i('Layout Style ${controller.screenType}');
    Log.i('Inline Bri ${controller.theme!.brightness}');
    Log.i('PhysicalSize(px):${flutterView.physicalSize.str()}');
    Log.i('PhysicalSize(dp):${(flutterView.physicalSize / flutterView.devicePixelRatio).str()}');
    Log.i('DevicePixelRatio:${flutterView.devicePixelRatio}');
    Log.i('Android DPI:${flutterView.devicePixelRatio * 160}');
    Log.i('Auto Connect ${controller.autoConnect}');
    WidgetsBinding.instance.addObserver(MetricsObserver());
    isInit = true;
    if (controller.autoConnect) {
      try {
        _receiveBoardCast();
        // ignore: empty_catches
      } catch (e) {}
    }
    if (GetPlatform.isAndroid) {
      try {
        _sendBoardCast();
        // ignore: empty_catches
      } catch (e) {}
    }
    _socketServer();
    await ADBInstaller.installAdbToEnvir();
    await initApi('ADB KIT', Config.versionName);
  }

  Widget? rootWidget;
}

class Print implements Printable {
  const Print();
  @override
  void print(DateTime time, Object object) {
    final String data = '[${twoDigits(time.hour)}:${twoDigits(time.minute)}:${twoDigits(time.second)}] $object';

    // ignore: avoid_print
    // core.print(data);
  }
}

String twoDigits(int n) {
  if (n >= 10) return "$n";
  return "0$n";
}

class MetricsObserver with WidgetsBindingObserver {
  @override
  void didChangeMetrics() {
    // ignore: deprecated_member_use
    FlutterView view = window;
    Log.v('didChangeMetrics invokded');
    Log.i('PhysicalSize(PX):${view.physicalSize.str()}');
    Log.i('PhysicalSize(DP):${(view.physicalSize / view.devicePixelRatio).str()}');
    Log.i('DevicePixelRatio:${view.devicePixelRatio}');
    Log.i('Android DPI:${view.devicePixelRatio * 160}');
  }
}

extension SizeExt on Size {
  String str() => 'Size(${width.toStringAsFixed(1)}, ${height.toStringAsFixed(1)})';
}
