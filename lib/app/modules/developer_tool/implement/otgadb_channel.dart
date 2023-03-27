// import 'package:adb_kit/app/modules/developer_tool/interface/adb_channel.dart';
// import 'package:adb_kit/utils/plugin_util.dart';
// import 'package:global_repository/global_repository.dart';
// import 'package:path/path.dart';

// // 使用安卓串口通信实现的adb通道
// class OTGADBChannel extends ADBChannel {
//   @override
//   Future<String?> execCmmand(String cmd) async {
//     // otg 会去掉 adb -s xxx shell
//     final String shell = cmd.replaceAll(RegExp('.*shell '), '');
//     final String? data = await PluginUtil.execCmd(shell);
//     Log.e('OTGADBChannel execCmmand -> $data');
//     return data;
//   }

//   @override
//   Future<void> install(String file) async {
//     final String fileName = basename(file);
//     await PluginUtil.pushToOTG(file, '/data/local/tmp/');
//     await PluginUtil.execCmd('pm install -r /data/local/tmp/$fileName');
//   }

//   @override
//   Future<void> push(String localPath, String remotePath) async {
//     await PluginUtil.pushToOTG(localPath, remotePath);
//   }

//   @override
//   Future<void> changeNetDebugStatus(int port) async {
//     final String? data = await PluginUtil.changeNetDbugStatus(port);
//     Log.w('changeNetDebugStatus ->$data');
//   }
// }
