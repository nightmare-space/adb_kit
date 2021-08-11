import 'package:adb_tool/app/modules/online_devices/controllers/online_controller.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adbutil/adbutil.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class OnlineView extends GetView<OnlineController> {
  @override
  Widget build(BuildContext context) {
    print('$this build');
    return Obx(() {
      if (controller.list.isEmpty) {
        return const Center(
          child: Text(
            '未发现运行设备',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(
            color: Colors.grey.withOpacity(0.2),
            width: 1.w,
          ),
        ),
        child: SizedBox(
          height: controller.list.length * 48.w,
          child: ListView.builder(
            itemCount: controller.list.length,
            padding: EdgeInsets.zero,
            itemBuilder: (c, i) {
              final DeviceEntity entity = controller.list[i];
              return InkWell(
                onTap: () async {},
                borderRadius: BorderRadius.circular(Dimens.gap_dp8),
                child: SizedBox(
                  height: Dimens.gap_dp48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.deepPurple,
                              ),
                              margin: EdgeInsets.only(
                                left: Dimens.gap_dp8,
                              ),
                              height: Dimens.gap_dp6,
                              width: Dimens.gap_dp6,
                            ),
                            SizedBox(
                              width: Dimens.gap_dp8,
                            ),
                            Text(
                              ' ${entity.address}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '(${entity.unique})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            tooltip: '让对方设备连接我',
                            icon: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity(),
                              child: const Icon(
                                Icons.wifi_tethering,
                                color: Colors.black54,
                              ),
                            ),
                            onPressed: () async {
                              showToast('发送请求成功');
                              Dio().get<void>(
                                'http://${entity.address}:$adbToolQrPort',
                              );
                            },
                          ),
                          SizedBox(
                            width: Dimens.gap_dp16,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: IconButton(
                              splashRadius: 40,
                              tooltip: '尝试连接这个设备',
                              icon: Center(
                                child: SvgPicture.asset(
                                  GlobalAssets.connect,
                                  color: Colors.black54,
                                  width: 20,
                                ),
                              ),
                              onPressed: () async {
                                AdbUtil.startPoolingListDevices();
                                AdbUtil.connectDevices(entity.address);
                              },
                            ),
                          ),
                          SizedBox(
                            width: Dimens.gap_dp8,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
