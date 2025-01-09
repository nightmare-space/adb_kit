import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/themes/app_colors.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart' as p;
import 'package:adb_util/adb_util_flutter.dart';
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:plugins/generated/intl.dart';

class PushFileDialog extends StatefulWidget {
  const PushFileDialog({
    super.key,
    this.paths,
    required this.device,
    this.installApk = false,
  });
  final List<String>? paths;
  final ADBDevice device;
  final bool installApk;

  @override
  State createState() => _PushFileDialogState();
}

class _PushFileDialogState extends State<PushFileDialog> {
  String currentFile = '';
  double progress = 1;
  int fileIndex = 0;
  int fileNum = 0;
  String speedPerSecond = '';
  String tip = '正在安装，请留意弹窗';

  @override
  void initState() {
    super.initState();
    fileNum = widget.paths!.length;
    push();
  }

  Future<void> push() async {
    String targetDir = '/storage/emulated/0';
    if (widget.installApk) {
      targetDir = '/data/local/tmp';
    }
    // TODO 提示是否覆盖
    for (final String sourcePath in widget.paths!) {
      final String fileName = p.basename(sourcePath);
      final int fileLen = await File(sourcePath).length();
      currentFile = fileName;
      setState(() {});
      String targetPath = '$targetDir/$fileName';
      getFileSize(targetPath, fileLen);
      String pushResult = await pushFile(
        serial: widget.device.serial,
        sourcePath: sourcePath,
        targetPath: targetPath,
        password: widget.device.password,
      );
      Log.i('pushResult -> $pushResult');
      if (widget.installApk) {
        String installResult = await pmInstall(
          serial: widget.device.serial,
          path: targetPath,
          password: widget.device.password,
        );
        Log.i('installResult -> $installResult');
        if (installResult.contains('Failure')) {
          showToast(installResult);
        }
        String rmResult = await rm(
          serial: widget.device.serial,
          path: targetPath,
          password: widget.device.password,
        );
        Log.i('rmResult -> $rmResult');
      }
      fileIndex++;
      // showToast('$name 已上传');
    }
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  String formatBytes(int bytes, [int decimals = 2]) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes == 0) ? 0 : (log(bytes) / log(1024)).floor();
    var size = bytes / pow(1024, i);
    return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
  }

  Future<void> getFileSize(String path, int len) async {
    AASClient aasClient = await AndroidAPIServerStarter.startServer(widget.device.serial);
    String url = aasClient.fileUrl(path);
    Dio dio = Dio();
    int previousSize = 0;
    DateTime previousTime = DateTime.now();
    Timer.periodic(500.milliseconds, (timer) async {
      late Response response;
      try {
        response = await dio.head(url);
      } catch (e) {
        Log.e('head error -> $e');
        if (!mounted) {
          timer.cancel();
        }
        return;
      }
      // Log.i('response.headers -> ${response.headers}');
      // Log.i('len $len target len -> ${response.headers[HttpHeaders.contentLengthHeader]}');

      int currentSize = int.parse(response.headers[HttpHeaders.contentLengthHeader]![0]);
      DateTime currentTime = DateTime.now();

      if (len == currentSize) {
        timer.cancel();
      }

      progress = currentSize / len;
      // Log.i('progress $progress');

      // 计算上传速度
      int sizeDifference = currentSize - previousSize;
      // Log.i('sizeDifference $sizeDifference bytes');
      Duration timeDifference = currentTime.difference(previousTime);
      double uploadSpeed;
      if (sizeDifference == 0) {
        speedPerSecond = '0';
        return;
      }
      uploadSpeed = sizeDifference / (timeDifference.inMilliseconds / 1000);
      // 更新上一次检查的文件大小和时间
      previousSize = currentSize;
      previousTime = currentTime;

      speedPerSecond = formatBytes(uploadSpeed.toInt());
      // Log.i('upload speed ${formatBytes(uploadSpeed.toInt())} bytes/second');
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Log.i('------>${P.of(context).common_switch}');
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(12.w),
        child: SizedBox(
          width: 400.w,
          child: Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: Text(
                        P.current.uploadingFile(currentFile),
                        style: TextStyle(
                          color: AppColors.fontColor,
                          fontWeight: bold,
                          fontSize: 14.w,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.w),
                LayoutBuilder(builder: (context, con) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(10.w),
                    child: Stack(
                      children: [
                        Container(
                          height: 6.w,
                          width: con.maxWidth,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withAlpha(opacity02),
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                        ),
                        AnimatedContainer(
                          duration: 100.milliseconds,
                          height: 6.w,
                          width: progress * con.maxWidth,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(10.w),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                SizedBox(height: 4.w),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '速度: $speedPerSecond/s',
                      style: TextStyle(
                        color: AppColors.fontColor,
                        fontWeight: bold,
                        fontSize: 14.w,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '(',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: bold,
                            ),
                          ),
                          TextSpan(
                            text: '$fileIndex',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: bold,
                            ),
                          ),
                          TextSpan(
                            text: '/$fileNum)',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontWeight: bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
