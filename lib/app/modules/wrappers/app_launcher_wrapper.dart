import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:app_launcher/app_launcher.dart';
import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
  @override
  void initState() {
    super.initState();
    startServer();
  }

  Future<void> startServer() async {
    await DexServer.startServer(
      widget.devicesEntity.serial,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!DexServer.serverStartList.contains(widget.devicesEntity.serial)) {
      return SpinKitDualRing(
        color: AppColors.accent,
        size: 20.w,
        lineWidth: 2.w,
      );
    }
    return const AppLauncher();
  }
}
