import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/src/utils/screen_util.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(20.w),
            ),
            child: Icon(
              Icons.adb,
              color: Colors.white,
              size: 72.w,
            ),
          ),
          SizedBox(height: 8.w),
          Text(
            'ADB TOOL',
            style: TextStyle(
              fontSize: 24.w,
              color: AppColors.fontColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.w),
          Text('版本号:${Config.version}')
        ],
      ),
    );
  }
}
