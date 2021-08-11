import 'dart:async';
import 'dart:io';
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
import 'package:termare_view/termare_view.dart';

class Global {
  factory Global() => _getInstance();
  Global._internal() {
    String executable = '';
    if (Platform.environment.containsKey('SHELL')) {
      executable = Platform.environment['SHELL'];
      // 取的只是执行的文件名
      executable = executable.replaceAll(RegExp('.*/'), '');
    } else {
      if (Platform.isMacOS) {
        executable = 'bash';
      } else if (Platform.isWindows) {
        executable = 'cmd';
      } else if (Platform.isAndroid) {
        executable = 'sh';
      }
    }
    Directory(RuntimeEnvir.homePath).createSync(recursive: true);
    Directory(RuntimeEnvir.tmpPath).createSync(recursive: true);
    final Map<String, String> environment = {
      'TERM': 'xterm-256color',
      'PATH': PlatformUtil.environment()['PATH'],
      'TMPDIR': RuntimeEnvir.tmpPath,
      'HOME': RuntimeEnvir.homePath,
    };
    const String workingDirectory = '.';
    pseudoTerminal = PseudoTerminal(
      executable: executable,
      workingDirectory: workingDirectory,
      environment: environment,
      arguments: ['-l'],
    );
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
    // NFC.isNDEFSupported.then((bool isSupported) {
    //   // print('isSupported -> $isSupported');
    //   // setState(() {
    //   //   _supportsNFC = isSupported;
    //   // });
    // }); // NFC.readNDEF returns a stream of NDEFMessage
    // final Stream<NDEFMessage> stream = NFC.readNDEF(once: false);

    // stream.listen((NDEFMessage message) {
    //   Log.i('records.length ${message.records.length}');

    //   Log.i('records.length ${message.records.first.data}');
    //   // for (final record in message.records) {
    //   //   print(
    //   //       'records: ${record.payload} ${record.data} ${record.type} ${record.tnf} ${record.languageCode}');
    //   // }
    //   // final NDEFMessage newMessage = NDEFMessage.withRecords([
    //   //   NDEFRecord.plain('macos10.15.7'),
    //   // ]);
    //   // message.tag.write(newMessage);
    //   RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
    //       .then((RawDatagramSocket socket) async {
    //     socket.broadcastEnabled = true;
    //     UdpUtil.boardcast(socket, message.records.first.data);
    //   });
    // });
  }

  Future<void> _socketServer() async {
    // 等待扫描二维码的连接
    HttpServerUtil.bindServer(
      adbToolQrPort,
      (address) {
        // 弹窗ß
        AdbUtil.connectDevices(address);
      },
    );
  }

  Future<void> initGlobal() async {
    print('initGlobal');
    if (isInit) {
      return;
    }
    isInit = true;
    _receiveBoardCast();
    _sendBoardCast();
    _initNfcModule();
    _socketServer();
  }
}
