import 'package:adb_kit/adb_kit.dart';
import 'package:adb_kit/app/controller/controller.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:adb_kit/utils/dex_server.dart';
import 'package:app_channel/app_channel.dart';
import 'package:flutter/material.dart';
import 'package:file_manager/file_manager.dart';
import 'package:get/get.dart';

class FilePlugin extends Pluggable {
  Future<AppChannel?> init(String serial) async {
    AppChannel? appChannel = await DexServer.startServer(serial);
    FMController controller = FMController();
    controller.setPort(appChannel!.port!, isRemote: true);
    Get.put<FMController>(controller);
    controller.enterDir('/sdcard');
    return appChannel;
  }

  @override
  Widget buildWidget(BuildContext context, DevicesEntity? device) {
    return FutureBuilder(
      future: init(device!.serial),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const FileManagerPage();
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  String get displayName => S.current.processManager;

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => '文件管理';

  @override
  void onTrigger() {}
}
