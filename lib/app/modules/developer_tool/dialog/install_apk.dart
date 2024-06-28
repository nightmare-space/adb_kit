import 'dart:io';

import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/themes/app_colors.dart';
import 'package:adb_kit/utils/plugin_util.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart' as p;

class InstallApkDialog extends StatefulWidget {
  const InstallApkDialog({
    Key? key,
    this.paths,
    required this.entity,
  }) : super(key: key);

  /// 路径列表
  final List<String>? paths;
  final DevicesEntity entity;

  @override
  State createState() => _InstallApkDialogState();
}

class _InstallApkDialogState extends State<InstallApkDialog> {
  String currentFile = '';
  double progress = 1;
  int fileIndex = 0;
  int fileNum = 0;

  @override
  void initState() {
    super.initState();
    fileNum = widget.paths!.length;
    if (Platform.isAndroid) {
      progress = 0;
    }
    push();
  }

  Future<void> push() async {
    PluginUtil.addHandler((call) {
      if (call.method == 'Progress') {
        progress = (call.arguments as double) / 100.0;
        Log.e('Progress -> $progress');
        setState(() {});
      }
    });
    StringBuffer stringBuffer = StringBuffer();
    for (final String path in widget.paths!) {
      final String name = p.basename(path);
      currentFile = name;
      setState(() {});
      try {
        await execCmd2([
          adb,
          '-s',
          widget.entity.serial,
          'install',
          '-t',
          path,
        ]);
        Log.i('install cmd -> adb -s ${widget.entity.serial} install -t "$path"');
      } on Exception catch (e) {
        stringBuffer.write('$name: $e\n');
      }
      fileIndex++;
      // showToast('$name 已上传');
    }
    if (stringBuffer.isNotEmpty) {
      showToast('安装Apk错误输出\n:${stringBuffer.toString().trim()}', duration: const Duration(milliseconds: 5000));
    }
    // ignore: use_build_context_synchronously
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        borderRadius: BorderRadius.circular(12.w),
        child: SizedBox(
          width: 400.w,
          height: 64.w,
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '安装 $currentFile 中...',
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
                            color: AppColors.fontColor,
                            fontWeight: bold,
                          ),
                        ),
                        TextSpan(
                          text: '$fileIndex',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: bold,
                          ),
                        ),
                        TextSpan(
                          text: '/$fileNum)',
                          style: TextStyle(
                            color: AppColors.fontColor,
                            fontWeight: bold,
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
                SizedBox(
                  height: 12.w,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.w),
                  child: LinearProgressIndicator(
                    value: progress,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
