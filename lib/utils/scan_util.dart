import 'package:global_repository/global_repository.dart';
import 'package:qrscan/qrscan.dart' as scanner;

import 'permission_utils.dart';
import 'socket_util.dart';

class ScanUtil {
  static Future<void> parseScan() async {
    await PermissionUtil.request();
    final String cameraScanResult = await scanner.scan();
    if (cameraScanResult == null) {
      return;
    }
    print('cameraScanResult -> $cameraScanResult');
    final List<String> localAddress = await PlatformUtil.localAddress();
    print(localAddress);
    for (final String localAddress in localAddress) {
      for (final String serverAddress in cameraScanResult.split(';')) {
        // 遍历二维码中的ip地址
        final List<String> serverAddressList = serverAddress.split('.');
        final List<String> localAddressList = localAddress.split('.');
        print('serverAddressList->$serverAddressList');
        print('localAddressList->$localAddressList');
        if (serverAddressList[0] == localAddressList[0] &&
            serverAddressList[1] == localAddressList[1] &&
            serverAddressList[2] == localAddressList[2]) {
          // 默认为前三个ip段相同代表在同一个局域网，可能更负责，由这学期学的计算机网路来看
          print('发现同一局域网IP');
          final NetworkManager socket = NetworkManager(
            serverAddress.split(':').first,
            int.tryParse(serverAddress.split(':').last),
          );
          await socket.connect();

          // socket.sendMsg(deviceIp);
        }
      }
    }
  }
}
