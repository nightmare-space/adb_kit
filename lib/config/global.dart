import 'dart:async';
import 'dart:io';

import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/global/provider/device_list_state.dart';
import 'package:adb_tool/global/provider/devices_state.dart';
import 'package:adb_tool/global/provider/process_info.dart';
import 'package:adb_tool/utils/adb_util.dart';
import 'package:adb_tool/utils/scrcpy_util.dart';
import 'package:adb_tool/utils/socket_util.dart';
import 'package:adb_tool/utils/udp_util.dart';
import 'package:adb_tool/utils/unique_util.dart';
import 'package:custom_log/custom_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';

class DeviceEntity {
  DeviceEntity(this.unique, this.address);
  final String unique;
  final String address;
  @override
  String toString() {
    return 'unique:$unique address:$address';
  }

  @override
  bool operator ==(dynamic other) {
    // 判断是否是非
    if (other is! DeviceEntity) {
      return false;
    }
    if (other is DeviceEntity) {
      return other.address == address;
    }
    return false;
  }

  @override
  int get hashCode => '$address'.hashCode;
}

class Global {
  factory Global() => _getInstance();
  Global._internal() {}
  bool lockAdb = false;
  bool isInit = false;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  // 由于使用的是页面级别的Provider，所以push后的context会找不到Provider的祖先节点
  ProcessState processState;
  DevicesState devicesState;
  DeviceListState deviceListState;
  String _documentsDir;
  void Function(DeviceEntity deviceEntity) findDevicesCall;
  static Global get instance => _getInstance();
  static Global _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  Future<void> _receiveBoardCast() async {
    RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      Config.udpPort,
    ).then((RawDatagramSocket socket) {
      socket.broadcastEnabled = true;
      socket.listen((RawSocketEvent rawSocketEvent) async {
        // 开启广播支持
        socket.broadcastEnabled = true;
        final Datagram datagram = socket.receive();
        if (datagram == null) {
          return;
        }
        final String message = String.fromCharCodes(datagram.data);
        // print('message -> $message');
        if (message.startsWith('find')) {
          final String unique = message.replaceAll('find ', '');
          if (unique != await UniqueUtil.getUniqueId()) {
            // 触发UI上的更新
            findDevicesCall?.call(
              DeviceEntity(unique, datagram.address.address),
            );
          }

          // print('发现设备');
          return;
        }
        if (message == 'macos10.15.7') {
          NiToast.showToast('发现来自IP：${datagram.address.address}的碰一碰');
          print('发现来自IP：${datagram.address.address}的碰一碰');
          ScrcpyUtil.showDeviceScreen(datagram.address.address);
        } else {
          print(
              'NFC标签的序列化为 $message 本设备的序列化为 ${await UniqueUtil.getUniqueId()}');
        }
      });
    });
  }

  Future<void> _sendBoardCast() async {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((
      RawDatagramSocket socket,
    ) async {
      socket.broadcastEnabled = true;
      print('发送自己');
      Timer.periodic(
        const Duration(seconds: 1),
        (Timer t) async {
          // for (int i = 0; i < 255; i++) {
          //   socket.send(
          //     'find ${await UniqueUtil.getUniqueId()}'.codeUnits,
          //     InternetAddress('192.168.39.$i'),
          //     Config.udpPort,
          //   );
          // }
          UdpUtil.boardcast(socket, 'find ${await UniqueUtil.getUniqueId()}');
        },
      );
    });
  }

  Future<void> _initNfcModule() async {
    print('启动_initNfcModule');
    if (!kIsWeb && !Platform.isAndroid) {
      return;
    }
    NFC.isNDEFSupported.then((bool isSupported) {
      print('isSupported -> $isSupported');
      // setState(() {
      //   _supportsNFC = isSupported;
      // });
    }); // NFC.readNDEF returns a stream of NDEFMessage
    final Stream<NDEFMessage> stream = NFC.readNDEF(once: false);

    stream.listen((NDEFMessage message) {
      Log.i('records.length ${message.records.length}');

      Log.i('records.length ${message.records.first.data}');
      // for (final record in message.records) {
      //   print(
      //       'records: ${record.payload} ${record.data} ${record.type} ${record.tnf} ${record.languageCode}');
      // }
      // final NDEFMessage newMessage = NDEFMessage.withRecords([
      //   NDEFRecord.plain('macos10.15.7'),
      // ]);
      // message.tag.write(newMessage);

      RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
          .then((RawDatagramSocket socket) async {
        socket.broadcastEnabled = true;
        // for (int i = 0; i < 255; i++) {
        //   socket.send(
        //     message.records.first.data.codeUnits,
        //     InternetAddress('192.168.39.$i'),
        //     Config.udpPort,
        //   );
        // }
        UdpUtil.boardcast(socket, message.records.first.data);
      });
    });
  }

  Future<void> _socketServer() async {
    // 等待扫描二维码的连接
    NetworkManager networkManager;
    networkManager = NetworkManager(
      InternetAddress.anyIPv4,
      Config.qrPort,
    );
    await networkManager.startServer((data) {
      Log.v('data -> $data');
      AdbUtil.connectDevices(data);
    });
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
    if (!kIsWeb && !Platform.isAndroid) {
      return;
    }
  }

  static String get documentsDir => instance._documentsDir;
}
