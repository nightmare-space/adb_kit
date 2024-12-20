import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/themes/app_colors.dart';
import 'package:adb_kit/utils/dex_server.dart';
import 'package:app_manager/app_manager.dart';
import 'package:app_manager/controller/app_manager_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:android_api_server_client/android_api_server_client.dart';

class AppManagerWrapper extends StatefulWidget {
  const AppManagerWrapper({
    super.key,
    required this.devicesEntity,
  });
  final DevicesEntity? devicesEntity;

  @override
  State createState() => _AppManagerWrapperState();
}

class _AppManagerWrapperState extends State<AppManagerWrapper> {
  AppManagerController controller = Get.find();
  AASClient? aas;

  @override
  void initState() {
    super.initState();
    startServer();
  }

  Future<void> startServer() async {
    aas = await DexServer.startServer(widget.devicesEntity!.serial);
    Get.put<AASClient>(aas!);
    controller.setAAS(aas!);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (aas == null) {
      return SpinKitPulse(
        color: Theme.of(context).colorScheme.primary,
      );
    }
    return AppManagerEntryPoint(
      // 直接进到设备的shell
      process: YanProcess()..exec('adb -s ${widget.devicesEntity!.serial} shell'),
    );
  }
}
