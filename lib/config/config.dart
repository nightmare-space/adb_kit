import 'dart:io';

import 'package:global_repository/global_repository.dart';

class Config {
  Config._();
  static String packageName = 'com.nightmare.adbtools';
  static Directory localDir = Directory(RuntimeEnvir.dataPath + '/AdbTool');
  static File historySaveFile = File(localDir.path + '/.history');
  static int versionCode = 28;
  static String versionName = '1.3.2';
  static String adbLocalPath = '/data/local/tmp';
  static String sdcard = '/sdcard';

  // 224.0.0.1 这个组播ip可以实现手机热点电脑，电脑发送组播，手机接收到
  // static InternetAddress multicastAddress = InternetAddress('224.0.0.1');
  // flutter package名，因为这个会影响assets的路径
  static String flutterPackage = '';

  static InternetAddress mDnsAddressIPv6 = InternetAddress('FF02::FB');
  static InternetAddress mDnsAddressIPv4 = InternetAddress('224.0.0.251');
}
