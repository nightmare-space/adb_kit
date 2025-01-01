import 'dart:io';

import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:adb_kit/themes/app_colors.dart';
import 'package:adb_kit/themes/theme.dart';
import 'package:adb_kit/themes/theme_light.dart';
import 'package:adb_kit/utils/adbd_find_util.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScanPage extends StatefulWidget {
  const QrScanPage({super.key});

  @override
  State createState() => _QrScanPageState();
}

class Addr {
  Addr(this.addr, this.name);
  String addr;
  final String name;
}

class _QrScanPageState extends State<QrScanPage> {
  ConfigController controller = Get.find();
  List<Addr> localAddresList = [];
  String removeScopeId(String address) {
    return address.split('%').first;
  }

  Future<List<Addr>> localAddress() async {
    List<Addr> addrs = [];
    final List<NetworkInterface> interfacesIpv4 = await NetworkInterface.list(type: InternetAddressType.IPv4);
    for (final NetworkInterface interface in interfacesIpv4) {
      for (final InternetAddress address in interface.addresses) {
        Log.i('interface.name:${interface.name} address:${address.address}');
        addrs.add(Addr(address.address, interface.name));
      }
    }
    final List<NetworkInterface> interfacesIpv6 = await NetworkInterface.list(type: InternetAddressType.IPv6);
    for (final NetworkInterface interface in interfacesIpv6) {
      for (final InternetAddress address in interface.addresses) {
        Log.i('interface.name:${interface.name} address:${address.address}');
        addrs.add(Addr(address.address, interface.name));
      }
    }
    // check address name start with 'wlan'
    bool hasWlan = false;
    for (final Addr addr in addrs) {
      if (addr.name.startsWith('wlan')) {
        hasWlan = true;
        break;
      }
    }
    if (hasWlan) {
      addrs = addrs.where((element) => element.name.startsWith('wlan')).toList();
    }
    for (Addr addr in addrs) {
      addr.addr = removeScopeId(addr.addr);
    }
    return addrs;
  }

  Future<void> getQrCode() async {
    await Future.delayed(const Duration(milliseconds: 100));
    localAddresList = await localAddress();
    // for (int i = 0; i < localAddresList.length; i++) {
    //   localAddresList[i].addr += ':${Global().successBindPort}';
    // }
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
      for (final Addr addr in localAddresList) {
        String url = '${isIPV6(addr.addr) ? '[${addr.addr}]' : addr.addr}:${Global().successBindPort}';
        children.add(
          GestureWithScale(
            onTap: () {
              Get.to(
                Theme(
                  data: light(),
                  child: Material(
                    color: Colors.black.withAlpha(opacity08),
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
                            QrImageView(
                              data: url,
                              version: QrVersions.auto,
                              size: 400.w,
                            ),
                            Text(url),
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
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12.w),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.w),
                    child: QrImageView(
                      data: url,
                      version: QrVersions.auto,
                      size: 140.w,
                      padding: EdgeInsets.all(0.w),
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    addr.name,
                    style: TextStyle(fontSize: 12.w, fontWeight: FontWeight.bold),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 140.w),
                    child: SelectableText(
                      url,
                      maxLines: 2,
                      style: TextStyle(fontSize: 10.w, fontWeight: FontWeight.bold),
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
        child: Row(children: children),
      );
    });
  }
}
