import 'dart:math';
import 'package:adb_tool/app/modules/online_devices/controllers/online_controller.dart';
import 'package:adb_tool/utils/adb_util.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

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
      return SizedBox(
        height: controller.list.length * Dimens.gap_dp54,
        child: ListView.builder(
          itemCount: controller.list.length,
          itemBuilder: (c, i) {
            final DeviceEntity entity = controller.list[i];
            return InkWell(
              onTap: () async {},
              borderRadius: BorderRadius.circular(Dimens.gap_dp8),
              child: SizedBox(
                height: Dimens.gap_dp48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Center(
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.deepPurple,
                            ),
                            margin: EdgeInsets.only(
                              left: Dimens.gap_dp8,
                            ),
                            height: Dimens.gap_dp8,
                            width: Dimens.gap_dp8,
                          ),
                          SizedBox(
                            width: Dimens.gap_dp4,
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
                            child: const Icon(Icons.arrow_drop_down),
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
                          tooltip: '尝试连接这个设备',
                          icon: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity(),
                            child: const Icon(Icons.arrow_drop_up),
                          ),
                          onPressed: () async {
                            AdbUtil.connectDevices(entity.address);
                          },
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
