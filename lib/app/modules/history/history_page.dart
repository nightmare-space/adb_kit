import 'package:adb_tool/app/controller/history_controller.dart';
import 'package:adb_tool/app/model/adb_historys.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';

class HistoryPage extends GetView<HistoryController> {
  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (kIsWeb || Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        title: const Text('历史连接'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
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
                onTap: () {},
                child: SizedBox(
                  height: Dimens.gap_dp56,
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
                          Text(
                            'IP地址：${adbEntity.address} 端口：${adbEntity.port}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '上次连接时间：${DateTime.parse(adbEntity.connectTime).getTimeString()}',
                            style: const TextStyle(),
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
