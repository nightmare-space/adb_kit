import 'dart:io';

import 'package:adb_tool/app/modules/online_devices/views/online_view.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ConnectPage extends StatefulWidget {
  @override
  _ConnectPageState createState() => _ConnectPageState();
}

class _ConnectPageState extends State<ConnectPage> {
  TextEditingController editingController = TextEditingController();
  List<String> addreses = [];
  @override
  void initState() {
    super.initState();
    getAddress();
  }

  @override
  void dispose() {
    editingController.dispose();
    super.dispose();
  }

  Future<void> getAddress() async {
    if (!GetPlatform.isWeb) {
      addreses = await PlatformUtil.localAddress();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (kIsWeb || Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        brightness: Brightness.light,
        centerTitle: true,
        elevation: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(
          '连接设备',
          style: TextStyle(
            height: 1.0,
            color: Theme.of(context).textTheme.bodyText2.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ItemHeader(color: CandyColors.purple),
                  Text(
                    '使用无界投屏安卓端扫码连接',
                    style: TextStyle(
                      fontSize: Dimens.font_sp16,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimens.gap_dp4),
              QrScanPage(),
              SizedBox(height: Dimens.gap_dp4),
              Row(
                children: [
                  const ItemHeader(color: CandyColors.candyBlue),
                  Text(
                    '输入对方设备IP连接',
                    style: TextStyle(
                      fontSize: Dimens.font_sp16,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimens.gap_dp4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TextField(
                      controller: editingController,
                      decoration: const InputDecoration(
                        hintText: '输入安卓设备的IP地址:端口号(可省略)',
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: SizedBox(
                        height: Dimens.setWidth(72),
                        width: Dimens.setWidth(72),
                        child: Material(
                          color: Colors.transparent,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.black.withOpacity(0.6),
                            ),
                            onPressed: () async {
                              if (editingController.text.isEmpty) {
                                showToast('IP不可为空');
                              }
                              Log.d('adb 连接开始');
                              AdbResult result;
                              try {
                                result = await AdbUtil.connectDevices(
                                  editingController.text,
                                );
                                showToast(result.message);
                              } on AdbException catch (e) {
                                showToast(e.message);
                              }
                              Log.d('adb 连接结束');
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimens.gap_dp4),
              Row(
                children: [
                  const ItemHeader(color: CandyColors.candyCyan),
                  Text(
                    '安卓设备访问URL进行连接',
                    style: TextStyle(
                      fontSize: Dimens.font_sp16,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimens.gap_dp8),
              Builder(builder: (_) {
                final List<Widget> list = [];
                for (final String address in addreses) {
                  final String uri = 'http://$address:$adbToolQrPort';
                  list.add(addressItem(uri));
                }
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12.w),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1.w,
                    ),
                  ),
                  child: Column(
                    children: list,
                  ),
                );
              }),
              SizedBox(
                height: Dimens.gap_dp8,
              ),
              Row(
                children: [
                  const ItemHeader(color: CandyColors.candyPink),
                  Text(
                    '通过设备发现',
                    style: TextStyle(
                      fontSize: Dimens.font_sp16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: Dimens.gap_dp8,
              ),
              OnlineView(),
            ],
          ),
        ),
      ),
    );
  }

  Widget addressItem(String uri) {
    return InkWell(
      onTap: () async {
        await Clipboard.setData(ClipboardData(
          text: uri,
        ));
        setState(() {});
        showToast('已复制到剪切板');
      },
      child: SizedBox(
        height: Dimens.gap_dp48,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.gap_dp8,
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.accent,
                ),
                height: Dimens.gap_dp6,
                width: Dimens.gap_dp6,
              ),
              SizedBox(width: Dimens.gap_dp8),
              Text(
                uri,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
    return NiCardButton(
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
        size: 120.0,
      ),
    );
  }
}
