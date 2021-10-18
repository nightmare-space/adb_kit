import 'package:adb_tool/app/modules/developer_tool/foundation/adb_channel.dart';
import 'package:adb_tool/utils/plugin_util.dart';

// 使用安卓串口通信实现的adb通道
class OTGADBChannel extends ADBChannel {
  @override
  Future<String> execCmmand(String cmd) async {
    final String shell = cmd.replaceAll(RegExp('.*shell'), '');
    PluginUtil.writeToOTG(shell + '\n');
    return '';
  }

  @override
  Future<void> install(String file) async {
    // TODO: implement install
    throw UnimplementedError();
  }

  @override
  Future<void> push(String localPath, String remotePath) async {
    await PluginUtil.pushToOTG(localPath, remotePath);
  }
}
