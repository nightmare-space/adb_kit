import 'package:adb_kit/adb_kit.dart' hide S;
import 'package:adb_kit/app/controller/controller.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:adb_kit/utils/dex_server.dart';
import 'package:app_channel/app_channel.dart';
import 'package:flutter/material.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:plugins/generated/l10n.dart';

class FilePlugin extends ADBKITPlugin {
  Future<AppChannel?> init(String serial) async {
    AppChannel? appChannel = await DexServer.startServer(serial);
    FMController controller = FMController();
    controller.setPort(appChannel.port!, isRemote: true);
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
        return Center(
          child: SpinKitDoubleBounce(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }

  @override
  ImageProvider<Object> get iconImageProvider => throw UnimplementedError();

  @override
  String get name => S.of(context!).file_manager;

  @override
  void onTrigger() {}
  @override
  String get id => '$this';
}
