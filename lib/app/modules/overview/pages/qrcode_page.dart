import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/themes/default_theme_data.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({Key key}) : super(key: key);

  @override
  _QrScanPageState createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  ConfigController controller = Get.find();
  List<String> localAddresList = [];
  Future<void> getQrCode() async {
    await Future.delayed(const Duration(milliseconds: 100));
    localAddresList = await PlatformUtil.localAddress();
    for (int i = 0; i < localAddresList.length; i++) {
      localAddresList[i] += ':${Global().successBindPort}';
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
        children.add(
          GestureWithScale(
            onTap: () {
              Get.to(
                Theme(
                  data: DefaultThemeData.light(),
                  child: Material(
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: NiCardButton(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        borderRadius: 12.w,
                        color: AppColors.contentBorder,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            QrImage(
                              data: addr,
                              version: QrVersions.auto,
                              size: 400.w,
                            ),
                            Text(addr),
                            SizedBox(height: 4.w),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                opaque: false,
                fullscreenDialog: false,
              );
              // AdbUtil.connectDevices('172.24.85.34:5555');
            },
            child: Material(
              color: Theme.of(context).surface2,
              borderRadius: BorderRadius.circular(12.w),
              child: Column(
                children: [
                  QrImage(
                    data: addr,
                    version: QrVersions.auto,
                    size: 140.w,
                    // foregroundColor: controller.theme.fontColor,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Text(
                      addr,
                      style: TextStyle(fontSize: 12.w),
                    ),
                  ),
                  SizedBox(height: 4.w),
                ],
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
