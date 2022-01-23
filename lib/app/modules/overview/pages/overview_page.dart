import 'package:adb_tool/app/controller/history_controller.dart';
import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/app/modules/online_devices/views/online_view.dart';
import 'package:adb_tool/app/modules/overview/list/devices_list.dart';
import 'package:adb_tool/app/modules/overview/pages/qrcode_page.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adb_tool/global/widget/menu_button.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/utils/scan_util.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key key}) : super(key: key);

  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  TextEditingController editingController = TextEditingController();
  List<String> addreses = [];
  @override
  void initState() {
    super.initState();
    getAddress();
  }

  Future<void> getAddress() async {
    if (!GetPlatform.isWeb) {
      addreses = await PlatformUtil.localAddress();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (kIsWeb || Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        centerTitle: true,
        elevation: 0.0,
        leading: Menubutton(scaffoldContext: context),
        title: const Text('面板'),
        actions: [
          if (GetPlatform.isAndroid)
            NiIconButton(
              child: SvgPicture.asset(
                GlobalAssets.qrCode,
                color: Colors.black,
              ),
              onTap: () async {
                ScanUtil.parseScan();
              },
            ),
          SizedBox(width: Dimens.gap_dp12),
        ],
      );
    }
    return Scaffold(
      appBar: appBar,
      body: buildBody(context),
    );
  }

  Padding buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: SingleChildScrollView(
        // padding: EdgeInsets.only(bottom: 100.w),
        physics: const BouncingScrollPhysics(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MacosContextMenuItem(
              //   content: Text('data'),
              // ),
              SizedBox(height: 8.w),
              CardItem(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ItemHeader(color: CandyColors.candyPink),
                        Text(
                          '已成功连接的设备',
                          style: TextStyle(
                            fontSize: 16.w,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const DevicesList(),
                  ],
                ),
              ),
              SizedBox(height: 8.w),
              connectCard(context),
              SizedBox(height: 8.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget connectCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardItem(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ItemHeader(color: CandyColors.candyBlue),
                  Text(
                    '输入对方设备IP连接',
                    style: TextStyle(
                      fontSize: Dimens.font_sp16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimens.gap_dp4),
              SizedBox(
                width: 414.w,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.w),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: editingController,
                          style: TextStyle(height: 1.0),
                          decoration: InputDecoration(
                            hintText: '格式为"IP地址:端口号 配对码"',
                            hintStyle: TextStyle(
                              fontSize: 14.w,
                              color: configController.theme.fontColor
                                  .withOpacity(0.8),
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 4.w,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.transparent,
                          child: Center(
                            child: NiIconButton(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black.withOpacity(0.6),
                              ),
                              onTap: () async {
                                if (editingController.text.isEmpty) {
                                  showToast('IP不可为空');
                                  return;
                                }
                                Log.d('adb 连接开始');
                                AdbResult result;
                                try {
                                  result = await AdbUtil.connectDevices(
                                    editingController.text,
                                  );
                                  showToast(result.message);
                                  final List<String> tmp =
                                      editingController.text.split(':');
                                  final String address = tmp[0];
                                  String port = '5555';
                                  if (tmp.length >= 2) {
                                    port = tmp[1];
                                  }
                                  HistoryController.updateHistory(
                                    address: address,
                                    port: port,
                                    name: address,
                                  );
                                } on AdbException catch (e) {
                                  showToast(e.message);
                                }
                                Log.d('adb 连接结束 ${result.message}');
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.w),
        CardItem(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const ItemHeader(color: CandyColors.purple),
                  Text(
                    '扫码连接',
                    style: TextStyle(
                      fontSize: Dimens.font_sp16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.w),
              const QrScanPage(),
              SizedBox(height: 8.w),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.w),
                ),
                child: Text(
                  '点击可放大二维码，只有同一局域网下对应的二维码才能正常扫描\n二维码支持adb工具、无界投屏、以及任意浏览器扫描\n也支持浏览器直接打开二维码对应IP进行连接',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12.w,
                  ),
                ),
              ),
              SizedBox(height: 8.w),
            ],
          ),
        ),
      ],
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
      borderRadius: BorderRadius.circular(12.w),
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
                  borderRadius: BorderRadius.circular(12.w),
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

class CardItem extends StatelessWidget {
  const CardItem({Key key, this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12.w),
      // border: Border.all(
      //   color: Colors.grey.withOpacity(0.2),
      //   width: 1.w,
      // ),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: child,
      ),
    );
  }
}
