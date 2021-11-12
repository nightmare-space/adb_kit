import 'package:adb_tool/app/modules/developer_tool/interface/adb_channel.dart';
import 'package:adbutil/adbutil.dart';
import 'package:path/path.dart';

// 使用二进制实现的adb通道
class BinADBChannel extends ADBChannel {
  BinADBChannel(this.serial);

  final String serial;
  @override
  Future<String> execCmmand(String cmd) async {
    String out = '';
    final List<String> cmds = cmd.split('\n');
    for (final String cmd in cmds) {
      out += await execCmd(cmd);
    }
    return out;
  }

  @override
  Future<void> install(String file) async {
    await execCmmand('adb -s $serial install -t $file');
  }

  @override
  Future<void> push(String localPath, String remotePath) async {
    final String fileName = basename(localPath);
    await execCmmand('adb -s $serial push $localPath $remotePath$fileName');
  }

  @override
  Future<void> changeNetDebugStatus(int port) async {
    if (port == 5555) {
      await execCmmand(
        'adb -s $serial tcpip 5555',
      );
    } else {
      await execCmmand(
        'adb -s $serial usb',
      );
    }
  }
}
