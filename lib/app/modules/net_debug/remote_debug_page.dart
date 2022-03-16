import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:adb_tool/app/modules/setting/setting_page.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adb_tool/global/widget/menu_button.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';

class RemoteDebugPage extends StatefulWidget {
  const RemoteDebugPage({Key key}) : super(key: key);

  @override
  _RemoteDebugPageState createState() => _RemoteDebugPageState();
}

class _RemoteDebugPageState extends State<RemoteDebugPage> {
  ConfigController configController = Get.find();
  bool adbDebugOpen = false;
  List<String> address = [];
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    address = await PlatformUtil.localAddress();
    Log.v('address->$address');
    setState(() {});
    final String result = await execCmd('getprop service.adb.tcp.port');
    if (result == '5555') {
      adbDebugOpen = true;
      setState(() {});
    }
  }

  Future<void> changeState() async {
    adbDebugOpen = !adbDebugOpen;
    setState(() {});
    final int value = adbDebugOpen ? 5555 : -1;
    await execCmd2([
      'su',
      '-c',
      'setprop service.adb.tcp.port $value&&stop adbd&&start adbd'
    ]);
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        title: Text(S.of(context).networkDebug),
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: configController.needShowMenuButton
            ? Menubutton(
                scaffoldContext: context,
              )
            : null,
      );
    }
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12.w,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).openLocalNetDebug,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.w,
                        ),
                      ),
                      AquaSwitch(
                        value: adbDebugOpen,
                        onChanged: (_) async {
                          changeState();
                        },
                      ),
                    ],
                  ),
                ),
                CardItem(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const ItemHeader(
                            color: CandyColors.candyPurpleAccent,
                          ),
                          Text(
                            S.of(context).localAddress,
                            style: TextStyle(
                              fontSize: Dimens.font_sp20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8.w,
                      ),
                      InkWell(
                        onTap: () async {
                          await Clipboard.setData(ClipboardData(
                            text: address.join('\n'),
                          ));
                          showToast('IP已复制');
                        },
                        borderRadius: BorderRadius.circular(12.w),
                        child: Text(
                          address.join('\n'),
                          style: TextStyle(
                            fontSize: Dimens.font_sp16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 8.w,
                ),
                CardItem(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const ItemHeader(color: CandyColors.candyBlue),
                          Text(
                            S.of(context).connectMethod,
                            style: TextStyle(
                              fontSize: Dimens.font_sp20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Text(
                              S.of(context).connectMethodDes1,
                              style: TextStyle(
                                fontSize: Dimens.font_sp14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: Dimens.gap_dp4),
                        child: Text(
                          S.of(context).connectMethodDes2,
                          style: TextStyle(
                            fontSize: Dimens.font_sp14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimens.gap_dp8,
                          vertical: Dimens.gap_dp8,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(Dimens.gap_dp8),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'adb connect \$IP',
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: '    \$IP代表的是本机IP',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: Dimens.gap_dp4),
                        child: Text(
                          S.of(context).connectMethodDes3,
                          style: TextStyle(
                            fontSize: Dimens.font_sp14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 8.0,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(Dimens.gap_dp8),
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: 'adb devices',
                                style: TextStyle(
                                  color: configController.theme.fontColor
                                      .withOpacity(0.6),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: Dimens.gap_dp8,
                ),
                Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                      child: Text(
                        S.of(context).connectMethodTip,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
