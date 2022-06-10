import 'dart:async';
import 'dart:io';

import 'package:global_repository/global_repository.dart';

class ADBFind {
  ADBFind._();

  static Future<List<String>> getLANDevices() async {
    List<String> address = await localAddress();
    List<String> list = address.first.split('.');
    List<String> devices = [];
    Completer lock = Completer();
    for (int i = 1; i < 255; i++) {
      String ip = [list[0], list[1], list[2], i].join('.');
      Socket.connect(
        ip,
        5555,
        timeout: const Duration(
          milliseconds: 1000,
        ),
      ).then((_) {
        devices.add(ip);
        // print('\x1b[32m $ip 成功');
      }).onError((error, stackTrace) {
        // print('\x1b[33merror : $error');
      }).whenComplete(() {
        if (i == 254) {
          lock.complete();
        }
        // print('\x1b[32m $ip whenComplete');
      });
    }
    await lock.future;
    return devices;
  }

  static Future<List<String>> localAddress() async {
    final List<String> address = [];
    final List<NetworkInterface> interfaces = await NetworkInterface.list(
      includeLoopback: false,
      type: InternetAddressType.IPv4,
    );
    for (final NetworkInterface netInterface in interfaces) {
      // Log.i('netInterface name -> ${netInterface.name}');
      // 遍历网卡
      for (final InternetAddress netAddress in netInterface.addresses) {
        // 遍历网卡的IP地址
        if (isAddress(netAddress.address)) {
          address.add(netAddress.address);
        }
      }
    }
    return address;
  }
}

bool isAddress(String content) {
  final RegExp regExp = RegExp(
      '((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})(\\.((2(5[0-5]|[0-4]\\d))|[0-1]?\\d{1,2})){3}');
  return regExp.hasMatch(content);
}

Future<void> main() async {
  Log.i('ADBFind.getLANDevices() : ${await ADBFind.getLANDevices()}');
}
