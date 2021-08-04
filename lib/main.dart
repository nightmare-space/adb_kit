library adb_tool;

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:signale/signale.dart';

import 'app/routes/app_pages.dart';
import 'config/config.dart';
import 'global/instance/global.dart';
import 'utils/assets_utils.dart';

void main() {
  RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  Global.instance;
  runApp(ToastApp(
    child: GetMaterialApp(
      enableLog: false,
      title: 'ADB TOOL',
      initialRoute: AdbPages.INITIAL,
      getPages: AdbPages.routes,
      defaultTransition: Transition.fade,
      debugShowCheckedModeBanner: false,
    ),
  ));
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  enableUdpMulti();
  installRes();
}

Future<void> installRes() async {
  if (kIsWeb) {
    return;
  }
  final filePath = RuntimeEnvir.binPath + '/app-release.apk';
  final Directory dir = Directory(RuntimeEnvir.binPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  AssetsUtils.copyAssetToPath('assets/app-release.apk', filePath);
  final ProcessResult result = await Process.run(
    'chmod',
    <String>['+x', filePath],
  );
  Log.d(
    '写入文件 release 输出 stdout:${result.stdout} stderr；${result.stderr}',
  );

  // print(await exec('scrcpy'));
}

Future<void> enableUdpMulti() async {
  // 这个是为了开启安卓的组播，安卓开启组播会增加耗电，所以默认是关闭的
  // 不过好像不生效
  if (Platform.isAndroid) {
    const MethodChannel methodChannel = MethodChannel('multicast-lock');
    final bool result = await methodChannel.invokeMethod<bool>('aquire');
    Log.d('result -> $result');
  }
  return;
  const String name = '_http._tcp';
  final MDnsClient client = MDnsClient(rawDatagramSocketFactory:
      (dynamic host, int port, {bool reuseAddress, bool reusePort, int ttl}) {
    return RawDatagramSocket.bind(host, port,
        reuseAddress: true, reusePort: false, ttl: ttl);
  });
  // Start the client with default options.
  await client.start();

  // Get the PTR record for the service.
  await for (final PtrResourceRecord ptr in client
      .lookup<PtrResourceRecord>(ResourceRecordQuery.serverPointer(name))) {
    // Use the domainName from the PTR record to get the SRV record,
    // which will have the port and local hostname.
    // Note that duplicate messages may come through, especially if any
    // other mDNS queries are running elsewhere on the machine.
    await for (final SrvResourceRecord srv in client.lookup<SrvResourceRecord>(
        ResourceRecordQuery.service(ptr.domainName))) {
      // Domain name will be something like "io.flutter.example@some-iphone.local._dartobservatory._tcp.local"
      final String bundleId =
          ptr.domainName; //.substring(0, ptr.domainName.indexOf('@'));
      print('Dart observatory instance found at '
          '${srv.target}:${srv.port} for "$bundleId".');
    }
  }
  // client.stop();
}
