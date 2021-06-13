import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:signale/signale.dart';

class QrScanPage extends StatefulWidget {
  @override
  _QrScanPageState createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
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
