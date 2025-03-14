import 'dart:convert';
import 'dart:io';

import 'package:adb_kit/adb_wrapper.dart';
import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/app/controller/controller.dart';
import 'package:adb_kit/app/modules/overview/list/devices_list.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:adb_kit/global/widget/item_header.dart';
import 'package:adb_kit/global/widget/menu_button.dart';
import 'package:adb_kit/utils/adbd_find_util.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:adb_kit/utils/scan_util.dart';
import 'package:adb_util/adb_util_flutter.dart';
import 'package:dart_adb/adb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart' hide exec;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../global/widget/card_item.dart';
import 'find_card.dart';
import 'connect_pair_card.dart';
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

  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      // padding: EdgeInsets.only(bottom: 100.w),
      physics: const BouncingScrollPhysics(),
      child: SafeAreaFix(
        child: Column(
          spacing: 8.w,
          children: [
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
            ConnectPairCard(),
            FindCard(),
            QRCodeContainer(port: Global.instance.successBindPort ?? 0),
            if (GetPlatform.isAndroid)
              CardItem(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const ItemHeader(color: CandyColors.deepPurple),
                        Text(
                          S.current.joinSocial,
                          style: TextStyle(
                            fontSize: 16.w,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            // https://t.me/nightmare_ly
                            launchUrlString('https://t.me/nightmare_ly');
                          },
                          borderRadius: BorderRadius.circular(8.w),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.w,
                            ),
                            child: Text(
                              'Telegram',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12.w,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            // const String url = 'mqqapi://card/show_pslcard?src_type=internal&version=1&uin=&card_type=group&source=qrcode';
                            const String url = 'https://pd.qq.com/s/h44e4i2oq?businessType=9';
                            // https://pd.qq.com/g/667273564040034447
                            const String originalUrl = 'https://qun.qq.com/qqweb/qunpro/share'
                                '?_wv=3&_wwv=128&appChannel=share&inviteCode=2mpAHhKfCOH'
                                '&businessType=9&from=246610&biz=ka&mainSourceId=share'
                                '&subSourceId=others&jumpsource=shorturl#/out';
                            final String base64UrlPrefix = base64Encode(utf8.encode(originalUrl));

                            final String url2 = 'mqqapi://forward/url?src_type=web&version=1&url_prefix=$base64UrlPrefix&t=1736670403844';

                            if (await canLaunchUrlString(url2)) {
                              await launchUrlString(url2);
                            } else {
                              showToast(S.current.openQQFail);
                              // throw 'Could not launch $url';
                            }
                          },
                          borderRadius: BorderRadius.circular(8.w),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.w,
                            ),
                            child: Text(
                              S.current.qqChannel,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12.w,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        //
                        InkWell(
                          onTap: () async {
                            // const String url = 'mqqapi://card/show_pslcard?src_type=internal&version=1&uin=&card_type=group&source=qrcode';
                            const String url = 'mqqapi://card/show_pslcard?src_type=internal&version=1&uin=615899007&card_type=group&source=qrcode';
                            if (await canLaunchUrlString(url)) {
                              await launchUrlString(url);
                            } else {
                              showToast('唤起QQ失败');
                              // throw 'Could not launch $url';
                            }
                          },
                          borderRadius: BorderRadius.circular(8.w),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.w,
                            ),
                            child: Text(
                              S.current.qqGroup,
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: 12.w,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ActionButton extends StatefulWidget {
  const ActionButton({
    super.key,
    this.onTap,
    required this.child,
  });
  final VoidCallback? onTap;
  final Widget child;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(12.w),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12.w),
        child: SizedBox(
          height: 40.w,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: DefaultTextStyle(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 14.w,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ),
    );
  }
}
