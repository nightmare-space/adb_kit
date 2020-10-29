import 'dart:io';

class PlatformUtil {
  // 判断当前的设备是否是移动设备
  static bool isMobilePhone() {
    return Platform.isAndroid || Platform.isIOS;
  }

  // 判断当前的设备是否是桌面设备
  static bool isDesktop() {
    return !isMobilePhone();
  }

  static String getFileName(String filePath) {
    return filePath.split(Platform.pathSeparator).last;
  }

  static String getRealPath(String filePath) {
    if (Platform.isWindows)
      return filePath.replaceAll('/', '\\').replaceAll(RegExp('/c'), 'C:');
    else
      return filePath;
  }

  static String getUnixPath(String prePath) {
    if (!RegExp('^[A-Z]:').hasMatch(prePath)) {
      return prePath.replaceAll('\\', '/');
    }
    final Iterable<Match> e = RegExp('^[A-Z]').allMatches(prePath);
    final String patch = e.elementAt(0).group(0);
    return prePath
        .replaceAll('\\', '/')
        .replaceAll(RegExp('^' + patch + ':'), '/' + patch.toLowerCase());
  }

  static Map<String, String> environment() {
    final Map<String, String> map = Map.from(Platform.environment);
    if (Platform.isAndroid) {
      // 只有按安卓需要
      map['PATH'] = '/data/data/com.example.adb_tool/files:' + map['PATH'];
    }
    return map;
  }
}
