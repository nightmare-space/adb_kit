import 'package:adb_tool/app/modules/overview/pages/qr_scan_page.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adb_tool/themes/candy_colors.dart';
import 'package:adb_tool/utils/adb_util.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

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
    if (kIsWeb || MediaQuery.of(context).orientation == Orientation.portrait) {
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
        padding: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  const ItemHeader(color: CandyColors.redPurple),
                  Text(
                    '使用ADB TOOL安卓端扫码连接',
                    style: TextStyle(
                      fontSize: Dimens.font_sp16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              QrScanPage(),
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
              SizedBox(
                height: Dimens.gap_dp8,
              ),
              SizedBox(
                height: Dimens.setWidth(72),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TextField(
                      decoration: InputDecoration(
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
                              await AdbUtil.connectDevices(
                                editingController.text,
                              );
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
                  const ItemHeader(color: CandyColors.candyCyan),
                  Text(
                    '安卓设备访问URL进行连接',
                    style: TextStyle(
                      fontSize: Dimens.font_sp16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Builder(builder: (_) {
                final List<Widget> list = [];
                for (final String address in addreses) {
                  final String uri = 'http://$address:$adbToolQrPort';
                  list.add(addressItem(uri));
                }
                return Column(
                  children: list,
                );
              })
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
                  color: Colors.deepPurple,
                ),
                height: Dimens.gap_dp8,
                width: Dimens.gap_dp8,
              ),
              SizedBox(width: Dimens.gap_dp16),
              Text(
                uri,
                style: TextStyle(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
