import 'package:flutter/foundation.dart';

class Config {
  Config._();
  static String baseURL =
      kReleaseMode ? 'https://api2.bmob.cn/1' : 'https://api2.bmob.cn/1';

  static String dbPath = '/data/data/com.nightmare/databases/user.db';
  static String curDevicesSerial = '';
  static Map<String, String> devicesMap = {};
}
