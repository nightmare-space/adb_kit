import 'dart:async';
import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/app/modules/developer_tool/model/screen_size.dart';
import 'package:adb_kit/themes/color_extension.dart';
import 'package:adb_kit/themes/theme.dart';
import 'package:adb_kit/utils/dex_server.dart';
import 'package:adb_kit/utils/utils.dart';
import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:global_repository/global_repository.dart' hide exec;
import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:adb_util/adb_util.dart';

class TaskManager extends StatefulWidget {
  const TaskManager({
    super.key,
    required this.serial,
  });

  final String serial;

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  AASClient? aas;
  Tasks tasks = Tasks(datas: []);
  ScreenSize? screenSize;
  @override
  void initState() {
    super.initState();
    initTask();
  }

  Future<void> initTask() async {
    aas = await DexServer.startServer(widget.serial);
    screenSize = ScreenSize.fromWM(
      await exec('adb -s ${widget.serial} shell wm size'),
    );
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
      }
      tasks = await aas!.getTasks();
      tasks.datas.removeWhere((element) => element.id == -1);
      // tasks = await TaskUtil.getTasks(widget.entity.serial);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (tasks.datas.isEmpty) {
      return SpinKitPulse(
        color: Theme.of(context).colorScheme.primary,
      );
    }
    return GridView.builder(
      itemCount: tasks.datas.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: screenSize!.radio,
      ),
      cacheExtent: 9999,
      itemBuilder: (c, i) {
        Task task = tasks.datas[i];
        return Column(
          children: [
            Text(tasks.datas[i].label),
            SizedBox(height: 4.w),
            Stack(
              alignment: Alignment.center,
              children: [
                buildSnapshotImage(task, Get.size.width / 2 - 16),
                buildCloseButton(task),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget buildIconImage(String package) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8.w),
      child: Image.network(
        aas!.iconUrl(package),
        width: 40.w,
        height: 40.w,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) {
          return Image.asset(
            'packages/app_manager/assets/placeholder.png',
            gaplessPlayback: true,
            width: 40.w,
            height: 40.w,
          );
        },
      ),
    );
  }

  Widget buildSnapshotImage(Task task, double width) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.w),
      child: Image.network(
        aas!.taskUrl(task.id),
        gaplessPlayback: true,
        width: width,
        height: width / screenSize!.radio,
        errorBuilder: (_, __, ___) {
          return Container(
            width: width,
            height: width / screenSize!.radio,
            color: Theme.of(context).colorScheme.surfaceContainer,
            child: Center(
              child: buildIconImage(task.topPackage),
            ),
          );
        },
      ),
    );
  }

  Widget buildCloseButton(Task task) {
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topRight,
        child: Material(
          color: Colors.transparent,
          child: IconButton(
            icon: Icon(
              Icons.clear,
              size: 24.w,
            ),
            onPressed: () {
              aas!.stopActivity(package: task.topPackage);
            },
          ),
        ),
      ),
    );
  }
}
