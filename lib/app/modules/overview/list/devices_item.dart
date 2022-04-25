import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/modules/developer_tool/developer_tool.dart';
import 'package:adb_tool/config/font.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adbutil/adbutil.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class DevicesItem extends StatefulWidget {
  const DevicesItem({
    Key key,
    this.devicesEntity,
  }) : super(key: key);
  // 可能是ip地址可能是设备编号
  final DevicesEntity devicesEntity;

  @override
  _DevicesItemState createState() => _DevicesItemState();
}

class _DevicesItemState extends State<DevicesItem>
    with TickerProviderStateMixin {
  String _title;
  AnimationController animationController;
  AnimationController progressAnimaCTL;
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
      await animationController?.forward();
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        await animationController?.reverse();
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
    _title = widget.devicesEntity.productModel ?? widget.devicesEntity.serial;
    return InkWell(
      borderRadius: BorderRadius.circular(Dimens.gap_dp8),
      onTap: () async {
        if (!widget.devicesEntity.isConnect) {
          showToast('设备未正常连接');
          return;
        }
        AdbUtil.stopPoolingListDevices();
        Get.put(AppManagerController());
        await Get.to(DeveloperTool(
          entity: widget.devicesEntity,
        ));
        Get.delete<AppManagerController>();
        AdbUtil.startPoolingListDevices();
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
                        height: Dimens.gap_dp6,
                        width: Dimens.gap_dp6,
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
                              widget.devicesEntity.stat,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.8),
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
                      if (isAddress(widget.devicesEntity.serial))
                        IconButton(
                          tooltip: '断开连接',
                          icon: Icon(
                            Icons.clear,
                            size: 24.w,
                          ),
                          onPressed: () async {
                            AdbUtil.stopPoolingListDevices();
                            await AdbUtil.disconnectDevices(
                              widget.devicesEntity.serial,
                            );
                            AdbUtil.startPoolingListDevices();
                            // Global.instance.pseudoTerminal.write(
                            //   'adb disconnect ${widget.devicesEntity.serial}\n',
                            // );
                          },
                        ),
                      if (!widget.devicesEntity.isConnect)
                        IconButton(
                          tooltip: '重新连接',
                          icon: Icon(
                            Icons.refresh,
                            size: 24.w,
                          ),
                          onPressed: () async {
                            Log.e(widget.devicesEntity.serial);
                            AdbUtil.reconnectDevices(
                              widget.devicesEntity.serial,
                            );
                          },
                        ),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 24.w,
                          color: Colors.black87,
                        ),
                        onPressed: () async {
                          if (!widget.devicesEntity.isConnect) {
                            showToast('设备未正常连接');
                            return;
                          }
                          AdbUtil.stopPoolingListDevices();
                          Get.put(AppManagerController());
                          await Get.to(DeveloperTool(
                            entity: widget.devicesEntity,
                          ));
                          Get.delete<AppManagerController>();
                          AdbUtil.startPoolingListDevices();
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
                        color:
                            Colors.blue.withOpacity(animationController.value),
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
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.15),
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
