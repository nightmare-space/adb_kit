
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/themes/default_theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScanPage extends StatefulWidget {
  @override
  _QrScanPageState createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  List<String> localAddresList = [];
  Future<void> getQrCode() async {
    localAddresList = await PlatformUtil.localAddress();
    for (int i = 0; i < localAddresList.length; i++) {
      localAddresList[i] += ':$adbToolQrPort';
    }
    setState(() {});
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
    if (localAddresList.isEmpty) {
      return const Material(
        color: Colors.transparent,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Builder(builder: (_) {
      final List<Widget> children = [];
      for (final String addr in localAddresList) {
        final Widget child = Column(
          children: [
            QrImage(
              data: addr,
              version: QrVersions.auto,
              size: 140.w,
            ),
            Text(addr),
            SizedBox(height: 4.w),
          ],
        );
        children.add(
          Hero(
            tag: addr,
            child: Material(
              color: Colors.transparent,
              child: NiCardButton(
                margin: EdgeInsets.zero,
                shadowColor: Colors.transparent,
                blurRadius: 0,
                spreadRadius: 0,
                color: AppColors.contentBorder,
                onTap: () {
                  Get.to(
                    Theme(
                      data: DefaultThemeData.light(),
                      child: Center(
                        child: Hero(
                          tag: addr,
                          child: Material(
                            color: Colors.black.withOpacity(0.8),
                            child: Center(
                              child: NiCardButton(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                borderRadius: 12.w,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    QrImage(
                                      data: addr,
                                      version: QrVersions.auto,
                                      size: 400.w,
                                    ),
                                    Text('$addr'),
                                    SizedBox(height: 4.w),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    opaque: false,
                    fullscreenDialog: true,
                  );
                  // AdbUtil.connectDevices('172.24.85.34:5555');
                },
                child: child,
              ),
            ),
          ),
        );
        children.add(SizedBox(
          width: 12.w,
        ));
      }
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: children,
        ),
      );
    });
  }
}
