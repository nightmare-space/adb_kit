import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/app/modules/overview/list/devices_list.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:adb_kit/global/widget/item_header.dart';
import 'package:adb_kit/global/widget/menu_button.dart';
import 'package:adb_kit/utils/adbd_find_util.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:adb_kit/utils/scan_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart' hide exec;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:adb_util/adb_util.dart';

import 'qrcode_container.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  TextEditingController editingController = TextEditingController();

  final ConfigController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    AppBar? appBar;
    if (ResponsiveBreakpoints.of(context).isMobile) {
      appBar = AppBar(
        centerTitle: true,
        elevation: 0.0,
        automaticallyImplyLeading: false,
        leading: Menubutton(scaffoldContext: context),
        title: Text(S.of(context).home),
        actions: [
          searchButton(context),
          if (GetPlatform.isAndroid)
            NiIconButton(
              child: SvgPicture.asset(
                GlobalAssets.qrCode,
                color: Theme.of(context).colorScheme.onSurface,
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
                        searchButton(context),
                      ],
                    ),
                    const DevicesList(),
                  ],
                ),
              ),
              SizedBox(height: 8.w),
              connectCard(context),
              SizedBox(height: 8.w),
              if (GetPlatform.isAndroid)
                CardItem(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const ItemHeader(color: CandyColors.deepPurple),
                          Text(
                            S.current.joinQQGroup,
                            style: TextStyle(
                              fontSize: 16.w,
                              fontWeight: bold,
                            ),
                          ),
                          if (GetPlatform.isDesktop) searchButton(context),
                        ],
                      ),
                      SizedBox(height: 12.w),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withAlpha(opacity01),
                          borderRadius: BorderRadius.circular(10.w),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                S.current.joinQQGT,
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 12.w,
                                ),
                              ),
                            ),
                            NiIconButton(
                              onTap: () async {
                                const String url = 'mqqapi://card/show_pslcard?src_type=internal&version=1&uin=&card_type=group&source=qrcode';
                                if (await canLaunchUrlString(url)) {
                                  await launchUrlString(url);
                                } else {
                                  showToast(S.current.openQQFail);
                                  // throw 'Could not launch $url';
                                }
                              },
                              child: const Icon(Icons.arrow_forward_ios),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  NiIconButton searchButton(BuildContext context) {
    return NiIconButton(
      child: Icon(
        Icons.search,
        color: Theme.of(context).colorScheme.onSurface,
      ),
      onTap: () async {
        List<String> adbDevices = await ADBFind.getLANDevices();
        Get.dialog(Center(
          child: Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.w),
            clipBehavior: Clip.hardEdge,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final String device in adbDevices)
                  InkWell(
                    onTap: () {
                      ADB.connectDevices('$device:5555');
                      Get.back();
                    },
                    child: SizedBox(
                      width: 200.w,
                      height: 48.w,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(left: 12.w),
                          child: Text(
                            device,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ));
      },
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
                          ),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Material(
                          color: Colors.transparent,
                          child: Center(
                            child: NiIconButton(
                              child: Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.black.withAlpha(opacity06),
                                size: 24.w,
                              ),
                              onTap: () async {
                                if (editingController.text.isEmpty) {
                                  showToast('IP不可为空');
                                  return;
                                }
                                Log.d('adb connect ${editingController.text} start');
                                ADBConnectResult? result;
                                try {
                                  result = await ADB.connectDevices(editingController.text);
                                  showToast(result.toString());
                                } catch (e) {
                                  if (e is NeedAuthenticate) {
                                    showToast('需要授权，留意弹窗');
                                    return;
                                  }
                                  Log.e(e);
                                  showToast('$e');
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
        QRCodeContainer(port: Global.instance.successBindPort ?? 0),
      ],
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
      // color: Theme.of(context).colorScheme.surfaceContainerLowest,
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: padding ?? EdgeInsets.all(8.w),
        child: child,
      ),
    );
  }
}
