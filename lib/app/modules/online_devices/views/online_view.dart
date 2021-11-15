import 'package:adb_tool/app/modules/online_devices/controllers/online_controller.dart';
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
    return Obx(() {
      if (controller.list.isEmpty) {
        return const Center(
          child: Text(
            '未发现运行设备',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }
      return SizedBox(
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
                            height: Dimens.gap_dp6,
                            width: Dimens.gap_dp6,
                          ),
                          SizedBox(
                            width: 2.w,
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
                            child: Icon(
                              Icons.wifi_tethering,
                              color: Colors.black54,
                              size: 20.w,
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
                        IconButton(
                          splashRadius: 40,
                          tooltip: '尝试连接这个设备',
                          icon: Center(
                            child: SvgPicture.asset(
                              GlobalAssets.connect,
                              color: Colors.black54,
                              width: 20.w,
                            ),
                          ),
                          onPressed: () async {
                            AdbUtil.startPoolingListDevices();
                            AdbResult result;
                            try {
                              result = await AdbUtil.connectDevices(
                                entity.address,
                              );
                              showToast(result.message);
                            } on AdbException catch (e) {
                              showToast(e.message);
                            }
                          },
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
      );
    });
  }
}
