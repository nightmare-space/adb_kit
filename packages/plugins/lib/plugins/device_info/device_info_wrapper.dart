import 'package:adb_kit/app/controller/controller.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class DeviceInfoWrapper extends StatefulWidget {
  const DeviceInfoWrapper({super.key, this.devicesEntity});
  final DevicesEntity? devicesEntity;

  @override
  State<DeviceInfoWrapper> createState() => _DeviceInfoWrapperState();
}

class _DeviceInfoWrapperState extends State<DeviceInfoWrapper> {
  DeviceInfoController infoController = Get.put(DeviceInfoController());
  @override
  void initState() {
    super.initState();
    infoController.initDevice(widget.devicesEntity!.serial);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 8.w),
        Expanded(child: DeviceInfo()),
      ],
    );
  }
}
