import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class DevicesList extends StatefulWidget {
  @override
  _DevicesListState createState() => _DevicesListState();
}

class _DevicesListState extends State<DevicesList> {
  final DevicesController controller = Get.find();
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void updateList() {
    // infos.clear();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DevicesController>(builder: (context) {
      // Log.e('刷新');
      return Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 54.0 * controller.devicesEntitys.length,
                child: AnimatedList(
                  controller: ScrollController(),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: false,
                  padding: const EdgeInsets.only(top: 0),
                  key: controller.listKey,
                  initialItemCount: controller.devicesEntitys.length,
                  itemBuilder: (
                    BuildContext context,
                    int index,
                    Animation<double> animation,
                  ) {
                    final DevicesEntity devicesEntity =
                        controller.devicesEntitys[index];
                    return SlideTransition(
                      position: animation
                          .drive(
                            CurveTween(curve: Curves.easeIn),
                          )
                          .drive(
                            Tween<Offset>(
                              begin: const Offset(1, 0),
                              end: const Offset(0, 0),
                            ),
                          ),
                      child: controller.itemBuilder(devicesEntity),
                    );
                  },
                ),
              ),
              Builder(builder: (_) {
                if (controller.adbIsStarting)
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitDualRing(
                        color: AppColors.accent,
                        size: 20.w,
                        lineWidth: 2.w,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        'ADB启动中',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                return const SizedBox();
              }),
              Builder(builder: (_) {
                if (!controller.adbIsStarting &&
                    controller.devicesEntitys.isEmpty)
                  return const Text(
                    '未发现设备',
                    style: TextStyle(color: Colors.grey),
                  );
                return const SizedBox();
              }),
            ],
          ),
        ],
      );
    });
  }
}
