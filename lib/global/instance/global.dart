import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:adb_kit/app/controller/controller.dart';
import 'package:adb_kit/app/modules/home/bindings/home_binding.dart';
import 'package:adb_kit/config/config.dart';
import 'package:adb_kit/utils/utils.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:multicast/multicast.dart';
import 'package:xterm/xterm.dart';
import 'dart:core' as core;
import 'dart:core';

// import 'behavior.dart';
import 'page_manager.dart';

extension PTYExt on Pty {
  void writeString(String data) {
    write(utf8.encode(data) as Uint8List);
  }
}

class Global {
  factory Global() => _getInstance()!;
  Global._internal() {
    // Log.defaultLogger.printer = const Print();
    Directory(RuntimeEnvir.binPath!).createSync(recursive: true);
    HomeBinding().dependencies();
  }

  static Global? get instance => _getInstance();
  static Global? _instance;

  static Global? _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  Terminal otgTerminal = Terminal();

  String drawerRoute = PageManager.instance!.pages.first.runtimeType.toString();
  Widget? page;
  void changeDrawerRoute(core.String route) {
    drawerRoute = route;
  }

  bool isInit = false;
  Multicast multicast = Multicast(
    port: adbToolUdpPort,
  );

  GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  // todo initial
  Pty? pty;
  Terminal terminal = Terminal();
  core.Future<void> initTerminal() async {
    if (Platform.isAndroid) {
      String? libPath = await getLibPath();
      RuntimeEnvir.put("PATH", '$libPath:${RuntimeEnvir.path}');
    }
    Map<String, String> envir = RuntimeEnvir.envir();
    // 设置HOME变量到应用内路径会引发异常
    // 例如 neofetch命令
    if (GetPlatform.isMobile) {
      envir['HOME'] = RuntimeEnvir.binPath!;
    }
    envir['LD_LIBRARY_PATH'] = '${RuntimeEnvir.binPath!}:/system/lib64';
    envir['TMPDIR'] = '/sdcard';
    envir['TERM'] = 'xterm-256color';
    envir['RUST_LOG'] = 'trace';
    String shell = 'sh';
    if (GetPlatform.isWindows) {
      shell = 'cmd';
    }
    pty ??= Pty.start(
      shell,
      arguments: ['-l'],
      environment: envir,
      workingDirectory: '/',
    );

    pty!.output.cast<List<int>>().transform(const Utf8Decoder()).listen(
      (event) {
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
          result = await AdbUtil.connectDevices(
            address,
          );
          showToast(result.message);
          HistoryController.updateHistory(
            address: address,
            port: '5555',
            name: address,
          );
        } on ADBException catch (e) {
          showToast(e.message!);
        }
      },
    );
  }

  List<String> androidFiles = [
    // 'adb',
    // 'adb.bin-armeabi',
    'libadb.so',
    'libadb_termux.so',
    // 'ld-android.so',
    'libabsl_bad_variant_access.so',
    'libabsl_base.so',
    'libabsl_city.so',
    'libabsl_cord.so',
    'libabsl_cord_internal.so',
    'libabsl_cordz_functions.so',
    'libabsl_cordz_handle.so',
    'libabsl_cordz_info.so',
    'libabsl_crc32c.so',
    'libabsl_crc_cord_state.so',
    'libabsl_crc_internal.so',
    'libabsl_die_if_null.so',
    'libabsl_examine_stack.so',
    'libabsl_exponential_biased.so',
    'libabsl_hash.so',
    'libabsl_int128.so',
    'libabsl_log_globals.so',
    'libabsl_log_internal_check_op.so',
    'libabsl_log_internal_format.so',
    'libabsl_log_internal_globals.so',
    'libabsl_log_internal_log_sink_set.so',
    'libabsl_log_internal_message.so',
    'libabsl_log_internal_nullguard.so',
    'libabsl_log_internal_proto.so',
    'libabsl_log_sink.so',
    'libabsl_low_level_hash.so',
    'libabsl_malloc_internal.so',
    'libabsl_raw_hash_set.so',
    'libabsl_raw_logging_internal.so',
    'libabsl_spinlock_wait.so',
    'libabsl_stacktrace.so',
    'libabsl_status.so',
    'libabsl_statusor.so',
    'libabsl_str_format_internal.so',
    'libabsl_strerror.so',
    'libabsl_strings.so',
    'libabsl_strings_internal.so',
    'libabsl_symbolize.so',
    'libabsl_synchronization.so',
    'libabsl_throw_delegate.so',
    'libabsl_time.so',
    'libabsl_time_zone.so',
    'libbrotlicommon.so',
    'libbrotlidec.so',
    'libbrotlienc.so',
    // 'libc++.so',
    'libc++_shared.so',
    // 'libc.so',
    // 'libdl.so',
    // 'liblog.so',
    'liblz4.so',
    // 'libm.so',
    'libprotobuf.so',
    'libusb-1.0.so',
    'libz.so.1',
    'libzstd.so.1',
    'libtermux-api.so',
  ];

  List<String> globalFiles = [
    'app_server',
  ];

  /// 复制一堆执行文件
  Future<void> installAdbToEnvir() async {
    if (kIsWeb) {
      return;
    }
    if (GetPlatform.isAndroid) {
      String? libPath = await getLibPath();
      File("${RuntimeEnvir.binPath}/adb").writeAsStringSync(
        '$libPath/libadb.so.so \$@',
      );
      final ProcessResult result = await Process.run(
        'chmod',
        <String>['+x', "${RuntimeEnvir.binPath}/adb"],
      );
      for (final String fileName in androidFiles) {
        final targetPath = '$libPath/$fileName.so';
        String filePath = '${RuntimeEnvir.binPath}/$fileName';
        Link link = Link(filePath);
        if (link.existsSync()) {
          link.deleteSync();
        }
        try {
          link.createSync(targetPath);
        } catch (e) {
          Log.e(e);
        }
        // Log.d(
        //   '更改文件权限 $fileName 输出 stdout:${result.stdout} stderr；${result.stderr}',
        // );
      }
    }
    await AssetsManager.copyFiles(
      localPath: '${RuntimeEnvir.binPath}/',
      android: [
        'termux-api',
        'termux-callback',
        'termux-usb',
        'termux-toast',
        'am',
        'am.apk',
      ],
      macOS: [],
      global: globalFiles,
      package: Config.flutterPackage,
    );
    Directory('${RuntimeEnvir.usrPath}/libexec').createSync(recursive: true);
    File('${RuntimeEnvir.binPath}/termux-callback').rename('${RuntimeEnvir.usrPath}/libexec/termux-callback');

    // final ProcessResult result = await Process.run(
    //   'chmod',
    //   <String>['+x', "${RuntimeEnvir.usrPath}/libexec/termux-callback"],
    // );
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
    Log.i('当前App内部主题 ${controller.theme!.brightness}');
    // Log.i('当前设备Root状态 ${await YanProcess().isRoot()}');
    Log.i('是否自动连接局域网设备 ${controller.autoConnect}');
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
    await installAdbToEnvir();
    // await initApi('ADB KIT', Config.versionName);
  }
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
