import 'dart:async';

import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:adb_tool/utils/dex_server.dart';
import 'package:adb_tool/utils/http/http.dart';
import 'package:adb_tool/utils/task.dart';
import 'package:adbutil/adbutil.dart';
import 'package:app_manager/app_manager.dart';
import 'package:app_manager/core/interface/app_channel.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:global_repository/global_repository.dart';

class TaskManager extends StatefulWidget {
  const TaskManager({Key key, this.entity}) : super(key: key);
  final DevicesEntity entity;

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  AppChannel channel;
  List<Task> tasks = [];
  @override
  void initState() {
    super.initState();
    Get.put(IconController());
    initTask();
  }

  initTask() async {
    channel = await DexServer.startServer(widget.entity.serial);
    Timer.periodic(Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
      }
      Response res =
          await httpInstance.get('http://127.0.0.1:${channel.port}/');
      List<dynamic> data = res.data;
      Log.i(data);

      List<Task> tasks = [];
      for (dynamic item in data) {
        if (item['id'] == -1) {
          continue;
        }
        tasks.add(Task(
          taskName: item['label'],
          package: item['topPackage'],
          taskId: item['id'].toString(),
        ));
      }
      this.tasks = tasks;
      // tasks = await TaskUtil.getTasks(widget.entity.serial);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 48.w),
      itemBuilder: (c, i) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: LayoutBuilder(builder: (context, c) {
            return SizedBox(
              width: 300.w,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(tasks[i].taskName ?? ''),
                  SizedBox(height: 12.w),
                  Expanded(
                    child: IntrinsicHeight(
                      child: Stack(
                        // alignment: Alignment.center,
                        // fit: StackFit.passthrough,
                        children: [
                          Container(
                            width: 300.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.w),
                              color: Theme.of(context).colorScheme.surface1,
                              boxShadow: [
                                // BoxShadow(
                                //   color: Theme.of(context)
                                //       .colorScheme
                                //       .shadow
                                //       .withOpacity(0.1),
                                //   offset: Offset(0, 0),
                                //   blurRadius: 10.w,
                                //   spreadRadius: 2.w,
                                // ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.w),
                              child: Builder(builder: (context) {
                                if (i == 0) {
                                  return LayoutBuilder(builder: (context, c) {
                                    return SizedBox(
                                      // height: 64.w,
                                      height: c.maxHeight,
                                      child: Center(
                                        child: SizedBox(
                                          width: 54.w,
                                          child: AppIconHeader(
                                            channel: channel,
                                            padding: EdgeInsets.zero,
                                            packageName: tasks[i].package,
                                          ),
                                        ),
                                      ),
                                    );
                                  });
                                }
                                return LayoutBuilder(builder: (context, c) {
                                  return Image.network(
                                    'http://127.0.0.1:${channel.port}/taskthumbnail?id=${tasks[i].taskId}',
                                    gaplessPlayback: true,
                                    height: c.maxHeight,
                                    errorBuilder: (_, __, ___) {
                                      return Container(
                                        height: 400.w,
                                        width: 300.w,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(12.w),
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
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    size: 24.w,
                                  ),
                                  onPressed: () {
                                    execCmd(
                                        'adb -s ${widget.entity.serial} shell am force-stop ${tasks[i].package}');
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
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
