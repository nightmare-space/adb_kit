import 'dart:io';

import 'package:adb_tool/app/modules/connect/connect_page.dart';
import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/modules/online_devices/views/online_view.dart';
import 'package:adb_tool/app/modules/overview/list/devices_list.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/pages/terminal.dart';
import 'package:adb_tool/global/widget/item_header.dart';
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
        brightness: Brightness.light,
        centerTitle: true,
        elevation: 0.0,
        leading: NiIconButton(
          child: const Icon(Icons.menu),
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text(
          '面板',
          style: TextStyle(
            height: 1.0,
            color: Theme.of(context).textTheme.bodyText2.color,
            fontWeight: FontWeight.bold,
          ),
        ),
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: appBar,
        body: buildBody(context),
      ),
    );
  }

  Padding buildBody(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 100.w),
        physics: BouncingScrollPhysics(),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // MacosContextMenuItem(
              //   content: Text('data'),
              // ),
              SizedBox(
                height: 8.w,
              ),
              CardItem(
                child: Column(
                  children: [
                    Row(
                      children: [
                        const ItemHeader(color: CandyColors.candyPink),
                        Text(
                          '已成功连接的设备',
                          style: TextStyle(
                            fontSize: Dimens.font_sp16,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    DevicesList(),
                  ],
                ),
              ),
              SizedBox(height: 8.w),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.w),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1.w,
                  ),
                ),
                padding: EdgeInsets.all(8.w),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const ItemHeader(color: CandyColors.candyPurpleAccent),
                        Text(
                          '运行ADB TOOL的设备',
                          style: TextStyle(
                            fontSize: Dimens.font_sp16,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Dimens.gap_dp8,
                    ),
                    OnlineView(),
                    SizedBox(
                      height: Dimens.gap_dp8,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                      child: Text(
                        '这儿发现了其他设备运行了本软件，也能快速连接~',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12.w,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.w),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12.w),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.2),
                    width: 1.w,
                  ),
                ),
                padding: EdgeInsets.all(8.w),
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
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: Dimens.gap_dp4),
                    SizedBox(
                      width: 414.w,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          TextField(
                            controller: editingController,
                            decoration: InputDecoration(
                              hintText: '格式为\"IP地址:端口号 配对码\"',
                              hintStyle: TextStyle(
                                fontSize: 14.w,
                              ),
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
                                      return;
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
                                    Log.d('adb 连接结束 ${result.message}');
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const ItemHeader(color: CandyColors.purple),
                        Text(
                          '扫码连接',
                          style: TextStyle(
                            fontSize: Dimens.font_sp16,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.w),
                    QrScanPage(),
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
              SizedBox(
                height: 8.w,
              ),

              CardItem(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const ItemHeader(color: CandyColors.yellow),
                        Text(
                          '快捷命令',
                          style: TextStyle(
                            fontSize: Dimens.font_sp16,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 0,
                      alignment: WrapAlignment.start,
                      runAlignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        ItemButton(
                          title: '开启服务',
                          onTap: () async {
                            const String cmd = 'adb start-server\r';
                            Global.instance.pseudoTerminal.write(cmd);
                            AdbUtil.startPoolingListDevices();
                          },
                        ),
                        ItemButton(
                          title: '停止服务',
                          onTap: () async {
                            const String cmd = 'adb kill-server\r';
                            Global.instance.pseudoTerminal.write(cmd);
                            AdbUtil.stopPoolingListDevices();
                            DevicesController controller = Get.find();
                            controller.clearDevices();
                          },
                        ),
                        ItemButton(
                          title: '重启服务',
                          onTap: () async {
                            const String cmd =
                                'adb kill-server && adb start-server\r';
                            Global.instance.pseudoTerminal.write(cmd);
                          },
                        ),
                        ItemButton(
                          title: '复制ADB KEY',
                          onTap: () async {
                            String homePath = '';
                            if (Platform.isMacOS) {
                              homePath = Platform.environment['HOME'];
                            } else if (Platform.isAndroid) {
                              homePath = RuntimeEnvir.binPath;
                            }
                            final File adbKey = File(
                              '$homePath/.android/adbkey.pub',
                            );
                            if (adbKey.existsSync()) {
                              await Clipboard.setData(
                                ClipboardData(
                                  text: adbKey.readAsStringSync(),
                                ),
                              );
                              showToast('已复制');
                            } else {
                              showToast('未发现adb key');
                            }
                          },
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8.w,
                    ),
                    const SizedBox(
                      height: 120,
                      child: TerminalPage(),
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

class ItemButton extends StatelessWidget {
  const ItemButton({Key key, this.title, this.onTap}) : super(key: key);
  final String title;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return NiCardButton(
      borderRadius: Dimens.gap_dp8,
      shadowColor: Colors.black,
      blurRadius: 0,
      spreadRadius: 0,
      onTap: onTap,
      color: AppColors.background,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(
            color: AppColors.accent,
            width: 1.w,
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 8.w,
        ),
        child: Column(
          children: [
            SizedBox(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1.w,
        ),
      ),
      padding: EdgeInsets.all(8.w),
      child: child,
    );
  }
}
