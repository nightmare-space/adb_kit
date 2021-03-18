import 'dart:math';

import 'package:adb_tool/app/modules/online_devices/controllers/online_controller.dart';
import 'package:adb_tool/config/dimens.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class OnlineView extends GetView<OnlineController> {
  @override
  Widget build(BuildContext context) {
    print('$this build');
    return Obx(
      () => SizedBox(
        height: controller.list.length * Dimens.gap_dp54,
        child: ListView.builder(
          itemCount: controller.list.length,
          itemBuilder: (c, i) {
            final DeviceEntity entity = controller.list[i];
            return InkWell(
              onTap: () async {},
              borderRadius: BorderRadius.circular(Dimens.gap_dp8),
              child: SizedBox(
                height: 48.0,
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
                    SizedBox(
                      width: Dimens.gap_dp4,
                    ),
                    Center(
                      child: Row(
                        children: [
                          Text(
                            ' ${entity.address}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '(${entity.unique})',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: '让对方设备连接我',
                      icon: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()..rotateZ(pi),
                        child: const Icon(Icons.send),
                      ),
                      onPressed: () async {
                        Dio().get<void>(
                          'http://${entity.address}:$adbToolQrPort',
                        );
                        // final NetworkManager socket = NetworkManager(
                        //   list[i].address,
                        //   adbToolQrPort,
                        // );
                        // await socket.connect();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () async {
                        Dio().get<void>(
                          'http://${entity.address}:$adbToolQrPort',
                        );
                        // final NetworkManager socket = NetworkManager(
                        //   list[i].address,
                        //   adbToolQrPort,
                        // );
                        // await socket.connect();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
