import 'package:flutter/material.dart';
import 'package:file_manager/file_manager.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import '../../generated/l10n.dart';
import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:adb_util/adb_util_flutter.dart';
import 'package:adb_interface/adb_interface.dart';

class FilePlugin extends ADBKITPlugin {
  @override
  Widget buildWidget(BuildContext context, ADBDevice device) {
    return FileManagerWrapper(device: device);
  }

  @override
  String get name => P.current.file_manager;

  @override
  String get id => '$this';
}

class FileManagerWrapper extends StatefulWidget {
  const FileManagerWrapper({
    super.key,
    required this.device,
  });
  final ADBDevice device;

  @override
  State<FileManagerWrapper> createState() => _FileManagerWrapperState();
}

class _FileManagerWrapperState extends State<FileManagerWrapper> {
  Future<AASClient?> init(String serial) async {
    AASClient? appChannel = await AndroidAPIServerStarter.startServer(serial);
    FMController controller = FMController();
    controller.setBaseUrl('${appChannel.baseUrl}/file');
    // TODO replace也不行，需要考虑多实例
    Get.replace(controller);
    Get.put(DownloadController());
    controller.enterHomeDir();
    await Future.delayed(1.seconds);
    return appChannel;
  }

  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = init(widget.device.serial);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const FileManagerPage();
        }
        return LoadingProgress();
      },
    );
  }
}
