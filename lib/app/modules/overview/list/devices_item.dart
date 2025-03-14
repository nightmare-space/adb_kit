import 'package:adb_kit/app/modules/developer_tool/developer_tool.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/themes/app_colors.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:adb_util/adb_util_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart' hide exec;

class DevicesItem extends StatefulWidget {
  const DevicesItem({
    super.key,
    required this.adbDevice,
  });
  // 可能是ip地址可能是设备编号
  final ADBDevice adbDevice;

  @override
  State createState() => _DevicesItemState();
}

class _DevicesItemState extends State<DevicesItem> with TickerProviderStateMixin {
  String? _title;
  late AnimationController animationController;
  late AnimationController progressAnimaCTL;
  double progressMax = 1;

  Future<void> getDeviceInfo() async {
    await Future.delayed(const Duration(milliseconds: 300), () {
      progressAnimaCTL.forward();
    });
    int time = 0;
    while (time < 3) {
      if (!mounted) {
        break;
      }
      await animationController.forward();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        await animationController.reverse();
      }
      time++;
    }
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    progressAnimaCTL = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 600,
      ),
    );
    progressAnimaCTL.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    animationController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    getDeviceInfo();
  }

  bool check = false;
  @override
  void dispose() {
    animationController.dispose();
    progressAnimaCTL.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _title = widget.adbDevice.productModel ?? widget.adbDevice.serial;
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.gap_dp8),
      onTap: () async {
        if (!widget.adbDevice.isConnect) {
          showToast(S.current.deviceNotConnect);
          return;
        }
        ADB.stopPoolingListDevices();
        await openPage(
          DeveloperTool(adbDevice: widget.adbDevice),
          title: S.current.devTools,
        );
        ADB.startPoolingListDevices();
      },
      child: SizedBox(
        height: 54.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.accent,
                        ),
                        height: 6.w,
                        width: 6.w,
                      ),
                      SizedBox(
                        width: 4.w,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _title ?? '',
                            style: TextStyle(
                              height: 1.2,
                              fontWeight: bold,
                              fontSize: 14.w,
                            ),
                          ),
                          SizedBox(
                            height: 2.w,
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
                              widget.adbDevice.stat,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withAlpha(opacity08),
                                fontSize: 10.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (widget.adbDevice.isNetworkDevice)
                        IconButton(
                          tooltip: S.current.disconnect,
                          icon: Icon(Icons.clear, size: 24.w),
                          onPressed: () async {
                            ADB.stopPoolingListDevices();
                            await ADB.disconnectDevice(widget.adbDevice.serial);
                            ADB.startPoolingListDevices();
                          },
                        ),
                      if (!widget.adbDevice.isConnect)
                        IconButton(
                          tooltip: S.current.reconnect,
                          icon: Icon(Icons.refresh, size: 24.w),
                          onPressed: () async {
                            Log.e(widget.adbDevice.serial);
                            ADB.reconnectDevices(widget.adbDevice.serial);
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 24.w,
                          color: Colors.black87,
                        ),
                        onPressed: () async {
                          if (!widget.adbDevice.isConnect) {
                            showToast(S.current.deviceNotConnect);
                            return;
                          }
                          ADB.stopPoolingListDevices();
                          await Get.to(DeveloperTool(
                            adbDevice: widget.adbDevice,
                          ));
                          ADB.startPoolingListDevices();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                ),
                child: Container(
                  height: 4.w,
                  decoration: BoxDecoration(
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.blue.o(animationController.value),
                        offset: const Offset(0.0, 0.0), //阴影xy轴偏移量
                        blurRadius: 16.0, //阴影模糊程度
                        spreadRadius: 1.0, //阴影扩散程度
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.w),
                    child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        Theme.of(context).primaryColor,
                      ),
                      backgroundColor: Theme.of(context).primaryColor.withAlpha(opacity015),
                      value: progressAnimaCTL.value * progressMax,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
