import 'package:adb_tool/app/modules/home/controllers/devices_controller.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:signale/signale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScanPage extends StatefulWidget {
  @override
  _QrScanPageState createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  final DevicesController controller = Get.find<DevicesController>();

  String content = '';
  List<String> localAddresList;
  Future<void> getQrCode() async {
    localAddresList = await PlatformUtil.localAddress();
    for (int i = 0; i < localAddresList.length; i++) {
      localAddresList[i] += ':$adbToolQrPort';
    }
    content = localAddresList.join('\n').trim();
    setState(() {});
    Log.v('content -> $content');
  }

  // Future<void> connectDevices(String ip) async {
  //   final DevicesEntity devicesEntity = controller.getDevicesByIp(ip);
  //   if (devicesEntity != null && !devicesEntity.connect()) {
  //     // 注释先别删，投屏 app 可能需要
  //     final ProcessResult result = await Process.run(
  //       'adb',
  //       [
  //         'disconnect',
  //         ip + ':5555',
  //       ],
  //       runInShell: true,
  //       includeParentEnvironment: true,
  //       environment: PlatformUtil.environment(),
  //     );
  //     // TODO 这儿有问题，有的设备远程调试的端口可能不是5555
  //     // Global.instance.pseudoTerminal.write('adb disconnect $ip:5555\n');
  //   }

  //   // Global.instance.pseudoTerminal.write('adb disconnect $ip:5555\n');
  //   final ProcessResult result = await Process.run(
  //     'adb',
  //     [
  //       'connect',
  //       ip + ':5555',
  //     ],
  //     runInShell: true,
  //     includeParentEnvironment: true,
  //     environment: PlatformUtil.environment(),
  //   );
  //   Log.w(result.stdout);
  //   if (result.stdout.toString().contains('unable to connect') ||
  //       result.stdout.toString().contains('failed to connect')) {
  //     showToast('连接失败，对方设备可能未打开网络ADB调试');
  //     return;
  //   }
  //   showToast((devicesEntity != null ? '尝试重新连接，' : '') + '等待授权');
  //   while (true) {
  //     await Future<void>.delayed(const Duration(milliseconds: 100), () {});
  //     DevicesEntity devicesEntity;
  //     for (int i = 0; i < controller.devicesEntitys.length; i++) {
  //       if (controller.devicesEntitys[i].serial.contains(ip)) {
  //         devicesEntity = controller.devicesEntitys[i];
  //       }
  //     }
  //     if (devicesEntity == null) {
  //       continue;
  //     }
  //     if (devicesEntity.connect()) {
  //       break;
  //     }
  //   }

  //   Log.v('result.stdout -> ${result.stdout}');
  //   Log.e('result.stderr -> ${result.stderr}');
  // }

  @override
  void initState() {
    super.initState();
    getQrCode();
  }

  @override
  void dispose() {
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
          shadowColor: Colors.transparent,
          blurRadius: 0,
          spreadRadius: 0,
          color: AppColors.contentBorder,
          onTap: () {
            // AdbUtil.connectDevices('172.24.85.34:5555');
          },
          child: QrImage(
            data: content,
            version: QrVersions.auto,
            size: 300.0,
          ),
        ),
      ],
    );
  }
}
