// 这是 android 端才有的页面
// 只有当 android 端作为热点的时候才行。

import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/config/font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';

class SearchIpPage extends StatefulWidget {
  const SearchIpPage({Key key}) : super(key: key);

  @override
  State createState() => _SearchIpPageState();
}

class _SearchIpPageState extends State<SearchIpPage> {
  final ConfigController controller = Get.find();
  List<String> addressList = [];
  @override
  void initState() {
    super.initState();
    getIp();
  }

  Future<void> getIp() async {
    while (mounted) {
      Log.v('-----------------');
      final String result = await exec('ip neigh');
      final List<String> tmp = [];
      for (final String line in result.split('\n')) {
        if (isAddress(line)) {
          final String address = line.split(' ').first;
          tmp.add(address);
          Log.v(line);
          if (addressList.contains(address)) {
            continue;
          } else {
            addressList.add(address);
            setState(() {});
          }
        }
      }
      addressList.removeWhere((element) => !tmp.contains(element));
      await Future<void>.delayed(
        const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        title: const Text('IP查看'),
        systemOverlayStyle: OverlayStyle.dark,
        leading: controller.needShowMenuButton
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              )
            : null,
      );
    }
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        left: false,
        child: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.w),
            border: Border.all(
              color: Colors.black.withOpacity(0.1),
              width: 1.w,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.gap_dp8),
            child: ListView(
              children: [
                for (String ip in addressList)
                  InkWell(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: ip));
                      showToast('IP已复制');
                    },
                    child: SizedBox(
                      height: Dimens.gap_dp48,
                      child: Row(
                        children: [
                          Text(
                            ip,
                            style: TextStyle(
                              fontWeight: bold,
                              fontSize: Dimens.font_sp16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (addressList.isNotEmpty)
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10.w),
                    ),
                    child: Text(
                      '该页面列表的是能与本机互通的IP，末尾为.1结尾的通常代表路由器的IP地址，其余的代表连接到本机的IP地址',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12.w,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
