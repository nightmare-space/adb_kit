import 'dart:async';
import 'dart:io';

import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/global/provider/devices_state.dart';
import 'package:adb_tool/global/provider/process_info.dart';
import 'package:adb_tool/page/home/provider/device_entitys.dart';
import 'package:adb_tool/utils/adb_util.dart';
import 'package:adb_tool/utils/scrcpy_util.dart';
import 'package:adb_tool/utils/socket_util.dart';
import 'package:adb_tool/utils/unique_util.dart';
import 'package:custom_log/custom_log.dart';
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
  Global._internal() {
    environment = PlatformUtil.environment();
    themeFollowSystem = true;
  }
  bool lockAdb = false;
  bool isInit = false;
  GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  // 由于使用的是页面级别的Provider，所以push后的context会找不到Provider的祖先节点
  ProcessState processState;
  DevicesState devicesState;
  DeviceEntitys deviceEntitys;
  Map<String, String> environment;
  bool themeFollowSystem;
  String _documentsDir;
  void Function(DeviceEntity deviceEntity) findDevicesCall;
  static Global get instance => _getInstance();
  static Global _instance;

  static Global _getInstance() {
    _instance ??= Global._internal();
    return _instance;
  }

  Future<void> _initNfcModule() async {
    RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      Config.multicastPort,
    ).then((RawDatagramSocket socket) {
      socket.broadcastEnabled = true;
      socket.writeEventsEnabled = true;
      socket.joinMulticast(Config.multicastAddress);
      print('Multicast group joined');

      socket.listen((RawSocketEvent rawSocketEvent) async {
        final Datagram datagram = socket.receive();
        if (datagram == null) {
          return;
        }
        final String message = String.fromCharCodes(datagram.data);
        print('message -> $message');
        if (message.startsWith('find')) {
          final String unique = message.replaceAll('find ', '');
          if (unique != await UniqueUtil.getUniqueId()) {
            findDevicesCall?.call(
              DeviceEntity(unique, datagram.address.address),
            );
          }

          // print('发现设备');
          return;
        }
        if (message == await UniqueUtil.getUniqueId()) {
          NiToast.showToast('发现来自IP：${datagram.address.address}的碰一碰');
          ScrcpyUtil.showDeviceScreen(datagram.address.address);
        } else {
          print(
              'NFC标签的序列化为 $message 本设备的序列化为 ${await UniqueUtil.getUniqueId()}');
        }
      });
    });
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0)
        .then((RawDatagramSocket socket) {
      print('Sending from ${socket.address.address}:${socket.port}');
      Timer.periodic(const Duration(seconds: 1), (Timer t) async {
        socket.send(
          'find ${await UniqueUtil.getUniqueId()}'.codeUnits,
          Config.multicastAddress,
          Config.multicastPort,
        );
      });
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
          .then((RawDatagramSocket socket) {
        print('Sending from ${socket.address.address}:${socket.port}');
        socket.send(
          message.records.first.data.codeUnits,
          Config.multicastAddress,
          Config.multicastPort,
        );
      });
    });
  }

  Future<void> _socketServer() async {
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
    _initNfcModule();
    _socketServer();
    if (!Platform.isAndroid) {
      return;
    }
  }

  static String get documentsDir => instance._documentsDir;
}
