import 'package:global_repository/global_repository.dart';

class Config {
  Config._();

  static String dbPath = '/data/data/com.nightmare/databases/user.db';
  static String packageName = 'com.nightmare.adbtool';
  static String curDevicesSerial = '';
  static Map<String, String> devicesMap = {};
  static String historyIp = '';
  static bool scrcpyExist = false;
  static Future<void> init() async {
    scrcpyExist = await PlatformUtil.cmdIsExist('scrcpy');
  }
}
