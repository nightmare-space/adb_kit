import 'dart:io';
import 'package:global_repository/global_repository.dart';

class UdpUtil {
  static Future<void> boardcast(RawDatagramSocket socket, String msg) async {
    // for (int i = 0; i < 255; i++) {
    //   socket.send(
    //     'find ${await UniqueUtil.getUniqueId()}'.codeUnits,
    //     InternetAddress('192.168.39.$i'),
    //     Config.udpPort,
    //   );
    // }
    socket.send(msg.codeUnits, InternetAddress('224.0.0.1'), adbToolUdpPort);
    await Future.delayed(const Duration(milliseconds: 10));
    // return;
    final List<String> address = await PlatformUtil.localAddress();
    for (final String addr in address) {
      final tmp = addr.split('.');
      tmp.removeLast();
      final String addrPrfix = tmp.join('.');
      for (int i = 0; i < 255; i++) {
        // print('在 $addrPrfix.$i 发送 $i');
        socket.send(
          msg.codeUnits,
          // 192.168.144.83
          InternetAddress('$addrPrfix.$i'),
          adbToolUdpPort,
        );
        await Future.delayed(const Duration(milliseconds: 1));
      }
      // print('addrPrfix -> $addrPrfix');
      // final InternetAddress address = InternetAddress(
      //   '$addrPrfix\.255',
      // );
      // socket.send(
      //   msg.codeUnits,
      //   address,
      //   adbToolUdpPort,
      // );
    }
  }
}
