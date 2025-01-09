import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/app/controller/history_controller.dart';
import 'package:adb_kit/app/model/adb_historys.dart';
import 'package:adb_kit/app/modules/overview/pages/overview_page.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/widget/menu_button.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart' hide exec;
import 'package:responsive_framework/responsive_framework.dart';
import 'package:adb_util/adb_util.dart';

class HistoryPage extends GetView<HistoryController> {
  const HistoryPage({
    super.key,
    this.showLeading = false,
  });
  final bool showLeading;
  ConfigController get configController => Get.find();

  @override
  Widget build(BuildContext context) {
    ColorScheme scheme = Theme.of(context).colorScheme;
    return Builder(builder: (context) {
      AppBar? appBar;
      if (ResponsiveBreakpoints.of(context).isMobile || configController.screenType == ScreenType.phone) {
        appBar = AppBar(
          title: Text(S.of(context).historyConnect),
          automaticallyImplyLeading: false,
          leading: showLeading ? Menubutton(scaffoldContext: context) : null,
        );
      }
      return Scaffold(
        appBar: appBar,
        body: GetBuilder<HistoryController>(
          builder: (ctl) {
            S s = S.of(context);
            if (controller.adbHistorys.data.isEmpty) {
              return Center(
                child: Text(
                  s.noHistoryTip,
                  style: TextStyle(
                    color: scheme.onSurface,
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
                          final ADBHistory adbEntity = controller.adbHistorys.data[i];
                          return Dismissible(
                            key: Key('$i'),
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
                          color: Colors.green.withAlpha(opacity01),
                          borderRadius: BorderRadius.circular(10.w),
                        ),
                        child: Text(
                          s.deleteHistoryTip,
                          style: TextStyle(color: Colors.green, fontSize: 12.w),
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
    });
  }

  InkWell buildItem(ADBHistory adbEntity, BuildContext context) {
    ColorScheme scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () async {
        ADBConnectResult result;
        try {
          // String suffix = ':${adbEntity.port}';
          // FIXME: 需要支持不是5555端口的设备
          result = await ADB.connectDevices('${adbEntity.address}:${adbEntity.port}');
          showToast(result.message);
        } catch (e) {
          showToast('$e');
        }
      },
      child: SizedBox(
        height: 64.w,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                            color: scheme.tertiary,
                            borderRadius: BorderRadius.circular(4.w),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.w,
                          ),
                          child: Text(
                            'id:${adbEntity.uniqueId}',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: scheme.onTertiary,
                              fontSize: 10.w,
                            ),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Container(
                          decoration: BoxDecoration(
                            color: scheme.secondary,
                            borderRadius: BorderRadius.circular(4.w),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
                          child: Text(
                            DateTime.parse(adbEntity.connectTime).getTimeString(),
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: scheme.onSecondary,
                              fontSize: 10.w,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      adbEntity.address,
                      style: TextStyle(
                        color: scheme.onSurface.withAlpha(opacity06),
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '端口:${adbEntity.port}',
                      style: TextStyle(
                        color: scheme.onSurface.withAlpha(opacity06),
                        fontSize: 12.w,
                        fontWeight: FontWeight.bold,
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
