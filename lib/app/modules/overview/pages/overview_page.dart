import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/controller/history_controller.dart';
import 'package:adb_tool/app/modules/overview/list/devices_list.dart';
import 'package:adb_tool/app/modules/overview/pages/qrcode_page.dart';
import 'package:adb_tool/config/font.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adb_tool/global/widget/menu_button.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:adb_tool/utils/scan_util.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({Key? key}) : super(key: key);

  @override
  State createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  TextEditingController editingController = TextEditingController();
  @override
  void initState() {
    super.initState();
  }

  final ConfigController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    AppBar? appBar;
    if (controller.screenType == ScreenType.phone ||
        ResponsiveWrapper.of(context).isPhone) {
      appBar = AppBar(
        centerTitle: true,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: Menubutton(scaffoldContext: context),
        title: Text(S.of(context).home),
        actions: [
          if (GetPlatform.isAndroid)
            NiIconButton(
              child: SvgPicture.asset(
                GlobalAssets.qrCode,
                color: Theme.of(context).colorScheme.onBackground,
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
      backgroundColor: Colors.transparent,
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
        left: false,
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
                          S.of(context).alreadyConnectDevice,
                          style: TextStyle(
                            fontSize: 16.w,
                            fontWeight: bold,
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
                    S.of(context).inputDeviceAddress,
                    style: TextStyle(
                      fontSize: Dimens.font_sp16,
                      fontWeight: bold,
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
                          style: const TextStyle(height: 1.2),
                          decoration: InputDecoration(
                            hintText: S.of(context).inputFormat,
                            hintStyle: TextStyle(
                              fontSize: 14.w,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onBackground
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
                                Log.d('adb 连接开始 ${editingController.text}');
                                AdbResult? result;
                                try {
                                  result = await AdbUtil.connectDevices(
                                    editingController.text,
                                  );
                                  // showToast(result.message);
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
                                } on ADBException catch (e) {
                                  Log.e(e);
                                  showToast(e.message!);
                                }
                                Log.d('adb 连接结束 $result');
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
        if(Global().showQRCode)CardItem(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const ItemHeader(color: CandyColors.purple),
                  Text(
                    S.of(context).scanToConnect,
                    style: TextStyle(
                      fontSize: Dimens.font_sp16,
                      fontWeight: bold,
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
                  S.of(context).scanQRCodeDes,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12.w,
                  ),
                ),
              ),
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
  const CardItem({Key? key, this.child, this.padding}) : super(key: key);
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12.w),
      clipBehavior: Clip.hardEdge,
      // border: Border.all(
      //   color: Colors.grey.withOpacity(0.2),
      //   width: 1.w,
      // ),
      color: Theme.of(context).surface1,
      child: Padding(
        padding: padding ?? EdgeInsets.all(8.w),
        child: child,
      ),
    );
  }
}
