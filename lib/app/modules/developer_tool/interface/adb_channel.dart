// 起初只有二进制的adb，后来多了web的adb和安卓otg的adb
// 所以抽象了这一层
abstract class ADBChannel {
  Future<String> execCmmand(String cmd);

  Future<void> push(String localPath, String remotePath);
  Future<void> install(String file);
  Future<void> changeNetDebugStatus(int port);
}
