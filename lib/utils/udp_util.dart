import 'dart:io';

import 'package:adb_tool/config/config.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

class UdpUtil {
  static Future<void> boardcast(RawDatagramSocket socket, String msg) async {
    final List<String> address = await PlatformUtil.localAddress();
    for (final String addr in address) {
      final tmp = addr.split('.');
      tmp.removeLast();
      final String addrPrfix = tmp.join('.');
      // print('addrPrfix -> $addrPrfix');
      final InternetAddress address = InternetAddress(
        '$addrPrfix\.255',
      );
      socket.send(
        msg.codeUnits,
        address,
        Config.udpPort,
      );
    }
  }
}
