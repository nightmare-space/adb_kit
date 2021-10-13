import 'package:adb_tool/app/modules/developer_tool/foundation/adb_channel.dart';
import 'package:adbutil/adbutil.dart';
import 'package:path/path.dart';

class BinADBChannel extends ADBChannel {
  BinADBChannel(this.serial);

  final String serial;
  @override
  Future<String> execCmmand(String cmd) async {
    return await execCmd(cmd);
  }

  @override
  Future<void> install(String file) async {
    await execCmmand('adb -s $serial install -t $file');
  }

  @override
  Future<void> push(String file) async {
    final String fileName = basename(file);
    await execCmmand('adb -s $serial push $file /sdcard/$fileName');
  }
}
