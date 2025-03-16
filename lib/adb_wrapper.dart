import 'package:adb_util/adb_util.dart';
import 'package:dart_adb/adb.dart';
import 'package:get/get.dart';

class ADBWrapper {
  static Future<dynamic> connectDevices(String ipAndPort) async {
    if (GetPlatform.isIOS) {
      ADBIO adbio = await ADBPure.connect(ipAndPort, 5555);
      return adbio;
    }
    return await ADB.connectDevices(ipAndPort);
  }
}
