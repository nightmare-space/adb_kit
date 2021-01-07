import 'dart:io';

import 'package:adb_tool/global/provider/process_info.dart';
import 'package:adb_tool/utils/socket_util.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

class Global {
  factory Global() => _getInstance();
  Global._internal() {
    environment = PlatformUtil.environment();
    themeFollowSystem = true;
  }
  bool isInit = false;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  // 由于使用的是页面级别的Provider，所以push后的context会找不到Provider的祖先节点
  ProcessState processState;
  Map<String, String> environment;
  bool themeFollowSystem;
  String _documentsDir;
  static Global get instance => _getInstance();
  static Global _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  Future<void> initGlobal() async {
    print('initGlobal');
    if (isInit) {
      return;
    }
    isInit = true;
    await PlatformUtil.init();
    NiProcess.exec('su');
    final NetworkManager networkManager = NetworkManager('0.0.0.0', 9001);
    await networkManager.startServer((data) {
      NiToast.showToast('发现碰一碰');
      print('data -> $data');
      connectDevices(data);
    });
    if (!Platform.isAndroid) {
      return;
    }
    NFC.isNDEFSupported.then((bool isSupported) {
      // setState(() {
      //   _supportsNFC = isSupported;
      // });
    }); // NFC.readNDEF returns a stream of NDEFMessage
    final Stream<NDEFMessage> stream = NFC.readNDEF(once: false);

    stream.listen((NDEFMessage message) {
      print('${message.type}');
      print('${message.id}');
      print('${message.tag.id}');
      print('${message.records.length}');
      print('${message.messageType}');
      for (final record in message.records) {
        print(
            'records: ${record.payload} ${record.data} ${record.type} ${record.tnf} ${record.languageCode}');
      }
      final NDEFMessage newMessage = NDEFMessage.withRecords([
        NDEFRecord.uri(Uri.parse('yan://nightmare.fun/index.html')),
      ]);
      message.tag.write(newMessage);
      sendIpToServer();
      // print("records: ${message.records.length}");
      // print("records: ${message.payload}");
      // print("records: ${message.records[0].data}");
      // print("records: ${message.records[1].payload}");
      // print("records: ${message.records[2].data}");
      // print("records: ${message.data}");
    });
  }

  Future<void> sendIpToServer() async {
    final ProcessResult result = await Process.run(
      'ip',
      ['route'],
    );
    // print(result.stdout);
    final String deviceIp = result.stdout.toString().trim().replaceAll(
          RegExp('.* '),
          '',
        );
    print('deviceIp ->$deviceIp');
    // 读本机的adb端口一起发送过去
    final NetworkManager socket = NetworkManager(
      '192.168.43.49',
      // '192.168.199.192',
      9003,
    );
    await socket.init();
    socket.sendMsg('192.168.43.1');
  }

  Future<void> connectDevices(String ip) async {
    // Navigator.pop(context);
    // print(
    //   PlatformUtil.environment()['PATH'],
    // );
    final ProcessResult result = await Process.run(
      'adb',
      [
        'connect',
        ip + ':5555',
      ],
      runInShell: true,
      includeParentEnvironment: true,
      environment: PlatformUtil.environment(),
    );
    if (result.stdout.toString().contains('unable to connect')) {
      NiToast.showToast('连接失败，对方设备可能未打开网络ADB调试');
    }
    print('result.stdout -> ${result.stdout}');
    print('result.stderr -> ${result.stderr}');
  }

  static String get documentsDir => instance._documentsDir;
}
