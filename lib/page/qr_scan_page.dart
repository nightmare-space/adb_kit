import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:adb_tool/global/widget/custom_card.dart';
import 'package:adb_tool/utils/socket_util.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';

int port;

class QrScanPage extends StatefulWidget {
  @override
  _QrScanPageState createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  NetworkManager networkManager;
  String content = '';
  // Random random = Random();
  Future<void> getQrCode() async {
    port = 9000 + Random().nextInt(9) * 10 + Random().nextInt(9);
    print('port -> $port');
    networkManager = NetworkManager('0.0.0.0', port);
    if (Platform.isWindows) {
      final ProcessResult result = await Process.run('ipconfig', []);
      // print(result.stdout);
      final RegExp regExp = RegExp('192.168.43.*|192.168.1.*');
      // regExp.firstMatch(result.stdout.toString()).group(0);
      String match = regExp.firstMatch('${result.stdout}').group(0);
      match = match.trim();
      print(match);
      content = match + ':$port';
      setState(() {});
    } else if (Platform.isAndroid) {
      final String ipRoute = await NiProcess.exec(
        'ip route',
      );
      for (String ip in ipRoute.split('\n')) {
        if (ip.startsWith('192')) {
          ip = ip.trim().replaceAll(RegExp('.* '), '');
          content += ip + ':$port\n';
          // connectDevices(ip);
          // ProcessResult result = Process.runSync('scrcpy', []);
          // print(result.stderr);
          // print(result.stdout);
        }
      }
    } else {
      final String ipResult = await NiProcess.exec('ifconfig | grep "inet"');
      print('ipResult->$ipResult');
      for (final String line in ipResult.split('\n')) {
        if (line.startsWith(RegExp('.{1,}inet '))) {
          // print('line -> $line');
          String tmp = line.replaceAll(RegExp('.{1,}inet '), '');
          // print('tmp -> $tmp');
          tmp = tmp.replaceAll(RegExp(' .*'), '');
          content = tmp + ':$port';
          setState(() {});
          print('tmp -> $tmp');
        }
      }
    }
    content = content.trim().replaceAll('\n', ';');
    setState(() {});
    print('content -> $content');
    // if (Platform.isAndroid) {
    //   content = '127.0.0.1:port';
    // }
    // String clientHost=
    await networkManager.startServer((data) {
      print('data -> $data');
      connectDevices(data);
    });
    // final NetworkManager socket = NetworkManager(
    //   '127.0.0.1',
    //   int.tryParse(content.split(':').last),
    // );
    // await socket.init();
    // socket.sendMsg(' 第 一 个socket');
    // final NetworkManager socket2 = NetworkManager(
    //   '127.0.0.1',
    //   int.tryParse(content.split(':').last),
    // );
    // await socket2.init();
    // socket2.sendMsg('第二个socket');
    // print(ipResult);
  }

  void connectDevices(String ip) {
    Navigator.pop(context);
    print(
      PlatformUtil.environment()['PATH'],
    );
    final ProcessResult result = Process.runSync(
      'adb',
      [
        'connect',
        ip + ':5555',
      ],
      runInShell: true,
      includeParentEnvironment: true,
      environment: PlatformUtil.environment(),
    );
    print(result.stdout);
    print(result.stderr);
    Process.runSync(
      'scrcpy-noconsole',
      ['-s', ip, '--turn-screen-off'],
      runInShell: true,
      includeParentEnvironment: true,
      environment: PlatformUtil.environment(),
    );
    print('ip -> $ip');
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
          child: QrImage(
            data: content,
            version: QrVersions.auto,
            size: 300.0,
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 16,
              ),
              child: Text(
                '使用魇系列任意app扫描即可快速连接\n- 设备与PC需要在同一局域网\n- 设备需要打开wifi adb调试',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
    // return Image.memory(result);
  }
}
