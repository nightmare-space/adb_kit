import 'dart:io';
import 'package:adb_tool/config/candy_colors.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/config/global.dart';
import 'package:adb_tool/global/widget/custom_card.dart';
import 'package:adb_tool/page/list/devices_list.dart';
import 'package:adb_tool/utils/socket_util.dart';
import 'package:custom_log/custom_log.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'provider/device_entitys.dart';

class QrScanPage extends StatefulWidget {
  @override
  _QrScanPageState createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  NetworkManager networkManager;
  String content = '';
  // Random random = Random();
  Future<void> getQrCode() async {
    // port = 9000 + Random().nextInt(9) * 10 + Random().nextInt(9);
    // print('port -> $port');
    networkManager = NetworkManager('0.0.0.0', Config.qrPort);
    if (Platform.isWindows) {
      // final ProcessResult result = await Process.run('ipconfig', []);
      // // print(result.stdout);
      // final RegExp regExp = RegExp('192.168.43.*|192.168.1.*');
      // // regExp.firstMatch(result.stdout.toString()).group(0);
      // String match = regExp.firstMatch('${result.stdout}').group(0);
      // match = match.trim();
      // print(match);
      // content = match + ':$port';
      // setState(() {});
    } else if (Platform.isAndroid) {
      final List<String> localAddress = await PlatformUtil.localAddress();
      for (final String localAddress in localAddress) {
        if (localAddress.startsWith('192.')) {
          content += localAddress + ':${Config.qrPort}\n';
        }
      }
      // final ProcessResult result = await Process.run('ip', ['route']);
      // final String ipRoute = result.stdout.toString();
      // for (String ip in ipRoute.split('\n')) {
      //   if (ip.startsWith('192')) {
      //     ip = ip.trim().replaceAll(RegExp('.* '), '');
      //     content += ip + ':$port\n';
      //     // connectDevices(ip);
      //     // ProcessResult result = Process.runSync('scrcpy', []);
      //     // print(result.stderr);
      //     // print(result.stdout);
      //   }
      // }
    } else {
      // final String ipResult = await NiProcess.exec('ifconfig | grep "inet"');
      // // print('ipResult->$ipResult');
      // for (final String line in ipResult.split('\n')) {
      //   if (line.startsWith(RegExp('.{1,}inet '))) {
      //     // print('line -> $line');
      //     String tmp = line.replaceAll(RegExp('.{1,}inet '), '');
      //     // print('tmp -> $tmp');
      //     tmp = tmp.replaceAll(RegExp(' .*'), '');
      //     content = tmp + ':$port';
      //     setState(() {});
      //     print('tmp -> $tmp');
      //   }
      // }
    }
    content = content.trim().replaceAll('\n', ';');
    setState(() {});
    Log.v('content -> $content');

    await networkManager.startServer((data) {
      Log.v('data -> $data');
      connectDevices(data);
    });
  }

  Future<void> connectDevices(String ip) async {
    DeviceEntitys deviceEntitys = Provider.of(context);
    NiToast.initContext(context);
    NiToast.showToast('扫描成功');

    DevicesEntity devicesEntity;
    for (int i = 0; i < deviceEntitys.devicesEntitys.length; i++) {
      if (deviceEntitys.devicesEntitys[i].serial.contains(ip)) {
        devicesEntity = deviceEntitys.devicesEntitys[i];
      }
    }
    if (devicesEntity != null) {
      if (!devicesEntity.connect()) {
        final ProcessResult result = await Process.run(
          'adb',
          [
            'disconnect',
            ip + ':5555',
          ],
          runInShell: true,
          includeParentEnvironment: true,
          environment: PlatformUtil.environment(),
        );
      }
    }
    final ProcessResult result = await Process.run(
      'adb',
      [
        'connect',
        ip + ':5555',
      ],
      runInShell: true,
      includeParentEnvironment: true,
      environment: PlatformUtil.environment(),
    );
    if (result.stdout.toString().contains('unable to connect')) {
      NiToast.showToast('连接失败，对方设备可能未打开网络ADB调试');
      return;
    }
    NiToast.showToast((devicesEntity != null ? '尝试重新连接，' : '') + '等待授权');
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 100), () {});
      DevicesEntity devicesEntity;
      for (int i = 0; i < deviceEntitys.devicesEntitys.length; i++) {
        if (deviceEntitys.devicesEntitys[i].serial.contains(ip)) {
          devicesEntity = deviceEntitys.devicesEntitys[i];
          //  if(deviceEntitys.devicesEntitys[i].connect()){
          //    break;
          //  }
        }
      }
      if (devicesEntity == null) {
        continue;
      }
      if (devicesEntity.connect()) {
        break;
      }
    }

    // deviceEntitys.lockAdb = true;
    // const MethodChannel channel = MethodChannel('scrcpy');
    // channel.invokeMethod<void>(ip + ':5555');

    Log.v('result.stdout -> ${result.stdout}');
    Log.e('result.stderr -> ${result.stderr}');
  }

  @override
  void initState() {
    super.initState();
    getQrCode();
  }

  @override
  void dispose() {
    networkManager.stopServer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return const Material(
        color: Colors.transparent,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        NiCardButton(
          onTap: () {
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: CandyColors.getRandomColor(),
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: QrImage(
              data: content,
              version: QrVersions.auto,
              size: 300.0,
            ),
          ),
        ), // Center(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ItemButton(
              title: '扫描后立即显示投屏',
              suffix: Switch(
                value: Config.conWhenScan,
                onChanged: (value) {
                  Config.conWhenScan = value;
                  setState(() {});
                },
              ),
              onTap: () async {
                Config.conWhenScan = !Config.conWhenScan;
                setState(() {});
              },
            ),
            Row(
              children: [
                ItemButton(
                  title: '重启ADB',
                  onTap: () async {
                    Global.instance.lockAdb = true;
                    const String cmd = 'adb kill-server\nadb start-server';
                    final String result = await exec('$cmd');
                    Log.v('result -> $result');
                    Global.instance.lockAdb = false;
                  },
                ),
                ItemButton(
                  title: '关闭ADB',
                  onTap: () async {
                    Global.instance.lockAdb = true;
                    const String cmd = 'adb kill-server';
                    final String result = await exec('$cmd');
                    await Future<void>.delayed(Duration(milliseconds: 100));
                    await exec('$cmd');
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  child: Text(
                    '使用魇系列任意app扫描即可快速连接\n- 扫码设备与本设备需要在同一局域网\n- 扫码设备需要打开wifi adb调试',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
    // return Image.memory(result);
  }
}

class ItemButton extends StatelessWidget {
  const ItemButton({
    Key key,
    this.title,
    this.onTap,
    this.suffix,
  }) : super(key: key);
  final String title;
  final Widget suffix;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return NiCardButton(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          // vertical: 8.0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (suffix != null) suffix
          ],
        ),
      ),
    );
  }
}
