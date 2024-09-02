import 'dart:async';
import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/app/modules/developer_tool/model/screen_size.dart';
import 'package:adb_kit/themes/color_extension.dart';
import 'package:adb_kit/themes/theme.dart';
import 'package:adb_kit/utils/dex_server.dart';
import 'package:adbutil/adbutil.dart';
import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:global_repository/global_repository.dart';

class TaskManager extends StatefulWidget {
  const TaskManager({Key? key, this.entity}) : super(key: key);
  final DevicesEntity? entity;

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  AppChannel? channel;
  Tasks tasks = Tasks(datas: []);
  late ScreenSize screenSize;
  @override
  void initState() {
    super.initState();
    initTask();
  }

  initTask() async {
    channel = await DexServer.startServer(widget.entity!.serial);
    screenSize = ScreenSize.fromWM(
      await execCmd('$adb -s ${widget.entity!.serial} shell wm size'),
    );
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
      }
      tasks = await channel!.getTasks();
      // tasks = await TaskUtil.getTasks(widget.entity.serial);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.datas.length,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 48.w),
      cacheExtent: 9999,
      itemBuilder: (c, i) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: LayoutBuilder(builder: (context, c) {
            return SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tasks.datas[i].label),
                  SizedBox(height: 12.w),
                  Stack(
                    alignment: Alignment.topRight,
                    // fit: StackFit.passthrough,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.w),
                          color: Theme.of(context).colorScheme.surface,
                          boxShadow: const [],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.w),
                          child: Builder(builder: (context) {
                            double height = c.maxHeight - 200;
                            if (i == 0) {
                              return LayoutBuilder(builder: (context, c) {
                                return SizedBox(
                                  // height: 64.w,
                                  height: height,
                                  width: height * screenSize.radio,
                                  child: Center(
                                    child: SizedBox(
                                      width: 54.w,
                                      child: AppIcon(
                                        channel: channel!,
                                        packageName: tasks.datas[i].topPackage,
                                      ),
                                    ),
                                  ),
                                );
                              });
                            }
                            return LayoutBuilder(builder: (context, c) {
                              return Image.network(
                                'http://127.0.0.1:${channel!.port}/taskthumbnail?id=${tasks.datas[i].id}',
                                gaplessPlayback: true,
                                height: height,
                                width: height * screenSize.radio,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    height: height,
                                    width: height * screenSize.radio,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.w),
                                    ),
                                  );
                                },
                              );
                            });
                          }),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 24.w,
                            ),
                            onPressed: () {
                              execCmd(
                                'adb -s ${widget.entity!.serial} shell am force-stop ${tasks.datas[i].topPackage}',
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.w),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
