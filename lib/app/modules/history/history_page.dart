import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/app/controller/history_controller.dart';
import 'package:adb_kit/app/model/adb_historys.dart';
import 'package:adb_kit/app/modules/overview/pages/overview_page.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/widget/menu_button.dart';
import 'package:adb_kit/themes/app_colors.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ConfigController configController = Get.find();
    AppBar? appBar;
    if (configController.screenType == ScreenType.phone || ResponsiveBreakpoints.of(context).isMobile) {
      appBar = AppBar(
        title: Text(S.of(context).historyConnect),
        automaticallyImplyLeading: false,
        leading: Menubutton(
          scaffoldContext: context,
        ),
      );
    }
    return Scaffold(
      appBar: appBar,
      body: GetBuilder<HistoryController>(
        builder: (ctl) {
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
          return SafeArea(
            left: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w),
              child: Stack(
                children: [
                  CardItem(
                    padding: EdgeInsets.zero,
                    child: ListView.builder(
                      itemCount: controller.adbHistorys.data.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (c, i) {
                        final Data adbEntity = controller.adbHistorys.data[i];
                        return Dismissible(
                          key: Key(i.toString()),
                          onDismissed: (direction) {
                            ctl.removeHis(i);
                          },
                          child: buildItem(adbEntity, context),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(8.w),
                      margin: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                      child: Text(
                        '左右滑动对应的历史可以删除',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12.w,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  InkWell buildItem(Data adbEntity, BuildContext context) {
    print('Theme.of(context).textTheme.bodyMedium!.color -> ${Theme.of(context).textTheme.bodyMedium!.color}');
    return InkWell(
      onTap: () async {
        AdbResult result;
        try {
          String suffix = '';
          suffix = ':${adbEntity.port}';
          result = await AdbUtil.connectDevices(
            adbEntity.address + suffix,
          );
          showToast(result.message);
        } on ADBException catch (e) {
          showToast(e.message!);
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      adbEntity.name,
                      style: TextStyle(
                        fontWeight: bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: CandyColors.green,
                            borderRadius: BorderRadius.circular(4.w),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.w,
                          ),
                          child: Text(
                            adbEntity.port,
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                              fontSize: 10.w,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 4.w,
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
                            DateTime.parse(adbEntity.connectTime).getTimeString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
                              fontSize: 10.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  adbEntity.address,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium!.color!.withOpacity(0.8),
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
