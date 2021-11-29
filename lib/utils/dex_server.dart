import 'dart:async';
import 'package:adbutil/adbutil.dart';
import 'package:app_manager/app_manager.dart';
import 'package:app_manager/core/interface/app_channel.dart';
import 'package:global_repository/global_repository.dart';
import 'package:pseudo_terminal_utils/pseudo_terminal_utils.dart';
import 'package:termare_pty/termare_pty.dart';

///
/// 无界投屏也会直接依赖这个
///
class DexServer {
  DexServer._();
  static List<String> serverStartList = [];
  static Future<void> startServer(String devicesId) async {
    if (serverStartList.contains(devicesId)) {
      return;
    }
    // 当锁用
    final Completer<void> completer = Completer();
    const String targetPath = '/data/local/tmp/app_server';
    // 上传server文件
    await AdbUtil.pushFile(
      devicesId,
      '${RuntimeEnvir.binPath}/app_server',
      targetPath,
    );
    final List<String> processArg =
        '-s $devicesId shell CLASSPATH=$targetPath app_process /data/local/tmp/ com.nightmare.applib.AppChannel'
            .split(' ');
    // CLASSPATH=/data/local/tmp/test app_process /data/local/tmp/ com.nightmare.applib.AppChannel
    final PseudoTerminal pty = TerminalUtil.getShellTerminal(
      exec: 'adb',
      arguments: processArg,
    );
    pty.startPolling();
    const String startTag = 'success start:';
    pty.out.listen((event) async {
      Log.w(event, tag: 'dex server');
      if (event.contains(startTag)) {
        serverStartList.add(devicesId);
        for (final String line in event.split('\n')) {
          if (line.contains(startTag)) {
            // 这个端口是对方设备成功绑定的端口
            final int remotePort = int.tryParse(line.replaceAll(startTag, ''));
            // 这个端口是本机成功绑定的端口
            final int localPort = await AdbUtil.getForwardPort(
              devicesId,
              rangeStart: 6000,
              rangeEnd: 6010,
              targetArg: 'tcp:$remotePort',
            );
            Log.d('localPort -> $localPort');
            // 这样才能保证列表正常
            final AppChannel appChannel = AppManager.globalInstance.appChannel;
            appChannel.port = localPort;
            if (appChannel is RemoteAppChannel) {
              appChannel.serial = devicesId;
            }
            AppManager.globalInstance.process = YanProcess()
              ..exec('adb -s $devicesId shell');
          }
        }
        completer.complete();
      }
      pty.schedulingRead();
    });
    return completer.future;
  }
}
