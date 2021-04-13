class Config {
  Config._();
  static String packageName = 'com.nightmare.adbtools';
  static String curDevicesSerial = '';
  static Map<String, String> devicesMap = {};
  static String historyIp = '';
  static bool conWhenScan = true;
  static String version = '1.0.6';
  // 224.0.0.1 这个组播ip可以实现手机热点电脑，电脑发送组播，手机接收到
  // static InternetAddress multicastAddress = InternetAddress('224.0.0.1');
  // flutter package名，因为这个会影响assets的路径
  static String flutterPackage = '';
}
