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
        adbToolUdpPort,
      );
    }
  }
}
