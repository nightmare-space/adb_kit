import 'dart:io';

import 'package:adb_tool/app/modules/developer_tool/interface/adb_channel.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/utils/plugin_util.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart' as p;

class InstallApkDialog extends StatefulWidget {
  const InstallApkDialog({
    Key key,
    this.paths,
    @required this.adbChannel,
  }) : super(key: key);
  final List<String> paths;
  final ADBChannel adbChannel;

  @override
  _InstallApkDialogState createState() => _InstallApkDialogState();
}

class _InstallApkDialogState extends State<InstallApkDialog> {
  String currentFile = '';
  double progress = 1;
  int fileIndex = 0;
  int fileNum = 0;

  @override
  void initState() {
    super.initState();
    fileNum = widget.paths.length;
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
    for (final String path in widget.paths) {
      final String name = p.basename(path);
      currentFile = name;
      setState(() {});
      try {
        await widget.adbChannel.install(path);
      } catch (e) {
        showToast('$name 安装失败，输出:$e');
      }
      fileIndex++;
      // showToast('$name 已上传');
    }
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
                        fontWeight: FontWeight.bold,
                        fontSize: 14.w,
                      ),
                    ),
                    RichText(
                        text: TextSpan(
                      children: [
                        const TextSpan(
                          text: '(',
                          style: TextStyle(
                            color: AppColors.fontColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '$fileIndex',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '/$fileNum)',
                          style: const TextStyle(
                            color: AppColors.fontColor,
                            fontWeight: FontWeight.bold,
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
