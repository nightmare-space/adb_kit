import 'package:adb_tool/app/controller/history_controller.dart';
import 'package:adb_tool/app/model/adb_historys.dart';
import 'package:adb_tool/global/widget/menu_button.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:get/get_state_manager/get_state_manager.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (kIsWeb || Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        title: const Text('历史连接'),
        leading: Menubutton(
          scaffoldContext: context,
        ),
      );
    }
    return Scaffold(
      appBar: appBar,
      body: GetBuilder<HistoryController>(
        builder: (_) {
          if (controller.adbHistorys.data.isEmpty) {
            return Center(
              child: Text(
                '这里就像开发者的钱包一样，什么也没有',
                style: TextStyle(
                  color: AppColors.fontDetail,
                ),
              ),
            );
          }
          return ListView.builder(
            itemCount: controller.adbHistorys.data.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (c, i) {
              final Data adbEntity = controller.adbHistorys.data[i];
              return InkWell(
                onTap: () async {
                  AdbResult result;
                  try {
                    String suffix = '';
                    if (adbEntity.port != null) {
                      suffix = ':${adbEntity.port}';
                    }
                    result = await AdbUtil.connectDevices(
                      adbEntity.address + suffix,
                    );
                    showToast(result.message);
                  } on AdbException catch (e) {
                    showToast(e.message);
                  }
                },
                child: SizedBox(
                  height: 64.w,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.gap_dp16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                adbEntity.name ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: CandyColors.orange,
                                  borderRadius: BorderRadius.circular(4.w),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4.w,
                                  vertical: 2.w,
                                ),
                                child: Text(
                                  adbEntity.address,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 10.w,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '上次连接时间：${DateTime.parse(adbEntity.connectTime).getTimeString()}',
                            style: const TextStyle(
                              color: AppColors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
