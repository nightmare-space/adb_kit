import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/utils/dex_server.dart';
import 'package:app_launcher/app_launcher.dart';
import 'package:app_manager/app_manager.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:app_manager/core/interface/app_channel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

class AppLauncherWrapper extends StatefulWidget {
  const AppLauncherWrapper({
    Key key,
    @required this.devicesEntity,
  }) : super(key: key);
  final DevicesEntity devicesEntity;

  @override
  _AppLauncherWrapperState createState() => _AppLauncherWrapperState();
}

class _AppLauncherWrapperState extends State<AppLauncherWrapper> {
  AppManagerController controller = Get.find();
  @override
  void initState() {
    super.initState();
    Get.put(IconController());
    startServer();
  }

  Future<void> startServer() async {
    AppChannel appChannel = await DexServer.startServer(
      widget.devicesEntity.serial,
    );
    controller.setAppChannel(appChannel);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!DexServer.serverStartList.keys.contains(widget.devicesEntity.serial)) {
      return SpinKitDualRing(
        color: AppColors.accent,
        size: 20.w,
        lineWidth: 2.w,
      );
    }
    return const AppLauncher();
  }
}
