import 'package:adb_tool/app/modules/developer_tool/foundation/adb_channel.dart';
import 'package:adbutil/adbutil.dart';

class BinADBChannel extends ADBChannel {
  @override
  Future<String> execCmmand(String cmd) async {
    return await execCmd(cmd);
  }
}
