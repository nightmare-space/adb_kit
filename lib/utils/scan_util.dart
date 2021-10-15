import 'package:adb_tool/app/modules/overview/pages/parse_qrcode_page.dart';
import 'package:adb_tool/app/modules/qrscan_page.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

extension IpString on String {
  bool isSameSegment(String other) {
    final List<String> serverAddressList = split('.');
    final List<String> localAddressList = other.split('.');
    if (serverAddressList[0] == localAddressList[0] &&
        serverAddressList[1] == localAddressList[1] &&
        serverAddressList[2] == localAddressList[2]) {
      // 默认为前三个ip段相同代表在同一个局域网，可能更复杂，涉及到网关之类的，由这学期学的计算机网路来看
      return true;
    }
    return false;
  }
}

class ScanUtil {
  ScanUtil._();
  static Future<void> parseScan() async {
    await PermissionUtil.requestCamera();
    final String cameraScanResult = await Get.to(
      const QrScan(),
      preventDuplicates: false,
      fullscreenDialog: true,
    );
    if (cameraScanResult == null) {
      return;
    }
    print('cameraScanResult -> $cameraScanResult');
    final List<String> connectAddress = cameraScanResult.split('\n');
    final List<String> localAddress = await PlatformUtil.localAddress();
    print(localAddress);
    // 这里应该优先排序，将同网关的地址放在最前面
    //
    Get.dialog(ParseQrcodePage(
      addressList: [
        ...connectAddress,
      ],
    ));
  }
}
