import 'dart:io';
import 'dart:math';

import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:adb_kit/global/widget/item_header.dart';
import 'package:adb_kit/themes/app_colors.dart';
import 'package:adb_kit/themes/theme_light.dart';
import 'package:adb_kit/utils/adbd_find_util.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'overview_page.dart';

class Addr {
  Addr(this.addr, this.name);
  String addr;
  final String name;
}

class QRCodeContainer extends StatefulWidget {
  const QRCodeContainer({super.key, required this.port});
  final int port;

  @override
  State<QRCodeContainer> createState() => _QRCodeContainerState();
}

class _QRCodeContainerState extends State<QRCodeContainer> {
  InternetAddressType type = InternetAddressType.IPv4;
  bool get isIPv4 => type == InternetAddressType.IPv4;
  bool get isIPv6 => type == InternetAddressType.IPv6;
  List<Addr> localAddresList = [];

  ConfigController controller = Get.find();
  String removeScopeId(String address) {
    return address.split('%').first;
  }

  bool hasWlan(List<Addr> addrs) {
    for (final Addr addr in addrs) {
      if (addr.name.startsWith('wlan')) {
        return true;
      }
    }
    return false;
  }

  Future<List<Addr>> getAddrs(InternetAddressType type) async {
    List<Addr> addrs = [];
    final List<NetworkInterface> interfacesIpv4 = await NetworkInterface.list(type: type);
    for (final NetworkInterface interface in interfacesIpv4) {
      for (final InternetAddress address in interface.addresses) {
        addrs.add(Addr(address.address, interface.name));
      }
    }
    return addrs;
  }

  Future<List<Addr>> localAddress() async {
    List<Addr> addrs = await getAddrs(type);
    // check address name start with 'wlan'
    bool hasWlan = this.hasWlan(addrs);
    if (hasWlan) {
      // if has wlan, only sshow wlan, do not contain mobile network
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
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getQrCode();
  }

  @override
  Widget build(BuildContext context) {
    return CardItem(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ItemHeader(color: CandyColors.purple),
              Text(
                S.of(context).scanToConnect,
                style: TextStyle(fontSize: 16.w, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Row(
            spacing: 4.w,
            children: [
              buildClip(InternetAddressType.IPv4),
              buildClip(InternetAddressType.IPv6),
            ],
          ),
          SizedBox(height: 8.w),
          Builder(builder: (_) {
            final List<Widget> children = [];
            for (final Addr addr in localAddresList) {
              String url = '${isIPV6(addr.addr) ? 'http://[${addr.addr}]' : addr.addr}:${widget.port}';
              Widget qrItem = Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12.w),
                child: LayoutBuilder(builder: (context, con) {
                  Log.i('con $con');
                  double minSide = min(con.maxWidth, con.maxHeight);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: QrImageView(
                          data: url,
                          version: QrVersions.auto,
                          size: minSide - 16.w,
                          padding: EdgeInsets.all(0.w),
                          eyeStyle: QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              );
              children.add(
                SizedBox(
                  width: 156.w,
                  child: Column(
                    children: [
                      GestureWithScale(
                        onTap: () {
                          Get.to(
                            GestureWithScale(
                              onTap: () {
                                Get.back();
                              },
                              child: qrItem,
                            ),
                            opaque: false,
                            fullscreenDialog: false,
                          );
                          // AdbUtil.connectDevices('172.24.85.34:5555');
                        },
                        child: qrItem,
                      ),
                      Text(
                        addr.name,
                        style: TextStyle(fontSize: 12.w, fontWeight: FontWeight.bold),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 156.w - 16.w),
                        child: SelectableText(
                          url,
                          maxLines: isIPv4 ? 1 : 2,
                          style: TextStyle(fontSize: 10.w, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(height: 4.w),
                    ],
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
          }),
          SizedBox(height: 8.w),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(opacity01),
              borderRadius: BorderRadius.circular(10.w),
            ),
            child: Text(
              S.of(context).scanQRCodeDes,
              style: TextStyle(
                color: Colors.green,
                fontSize: 12.w,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildClip(InternetAddressType type) {
    bool isSelect = this.type == type;
    Color foreColor = Theme.of(context).colorScheme.primary;
    Color backColor = Theme.of(context).colorScheme.primary.withOpacity(0.4);
    Color unselectForeColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.5);
    Color unselectBackColor = Theme.of(context).colorScheme.primary.withOpacity(0.15);
    return GestureDetector(
      onTap: () {
        this.type = type;
        setState(() {});
        getQrCode();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelect ? backColor : unselectBackColor,
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.w),
            child: Text(
              '$type'.replaceAll(RegExp('.*: '), ''),
              style: TextStyle(
                fontSize: 12.w,
                fontWeight: FontWeight.bold,
                color: isSelect ? foreColor : unselectForeColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
