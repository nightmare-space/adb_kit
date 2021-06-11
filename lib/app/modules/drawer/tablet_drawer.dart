import 'dart:io';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:url_launcher/url_launcher.dart';

import '../help_page.dart';

class TabletDrawer extends StatefulWidget {
  const TabletDrawer({
    Key key,
    this.onChange,
    this.index,
  }) : super(key: key);
  final void Function(int index) onChange;
  final int index;

  @override
  _TabletDrawerState createState() => _TabletDrawerState();
}

class _TabletDrawerState extends State<TabletDrawer> {
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(Dimens.gap_dp20),
              bottomRight: Radius.circular(Dimens.gap_dp20),
            ),
          ),
          child: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Builder(
                builder: (_) {
                  if (orientation == Orientation.portrait) {
                    return buildBody(context);
                  }
                  return SingleChildScrollView(
                    child: SizedBox(
                      child: buildBody(context),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Column buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: Dimens.gap_dp16,
            ),
            _DrawerItem(
              title: '主页',
              value: 0,
              groupValue: widget.index,
              onTap: (index) {
                widget.onChange?.call(index);
              },
              iconData: Icons.home,
            ),
            _DrawerItem(
              title: '连接设备',
              value: 1,
              groupValue: widget.index,
              onTap: (index) {
                widget.onChange?.call(index);
              },
              iconData: Icons.data_saver_off,
            ),
            if (!kIsWeb && Platform.isAndroid)
              _DrawerItem(
                value: 2,
                groupValue: widget.index,
                title: '安装到系统',
                iconData: Icons.file_download,
                onTap: (index) {
                  widget.onChange?.call(index);
                },
              ),
            // _DrawerItem(
            //   title: '当前设备ip',
            //   onTap: () {},
            // ),
            if (!kIsWeb && Platform.isAndroid)
              Column(
                children: [
                  _DrawerItem(
                    value: 3,
                    groupValue: widget.index,
                    title: '查看局域网ip',
                    onTap: (index) {
                      widget.onChange?.call(index);
                    },
                    iconData: Icons.wifi_tethering,
                  ),
                  _DrawerItem(
                    value: 4,
                    groupValue: widget.index,
                    iconData: Icons.signal_wifi_4_bar,
                    title: '远程调试',
                    onTap: (index) {
                      widget.onChange?.call(index);
                    },
                  ),
                ],
              ),
            _DrawerItem(
              value: 5,
              groupValue: widget.index,
              title: '执行自定义命令',
              iconData: Icons.code,
              onTap: (index) {
                widget.onChange?.call(index);
              },
            ),

            _DrawerItem(
              value: 6,
              groupValue: widget.index,
              title: '历史连接',
              iconData: Icons.history,
              onTap: (index) async {
                widget.onChange?.call(index);
              },
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DrawerItem(
              groupValue: widget.index,
              title: '其他平台下载',
              onTap: (index) async {
                const String url = 'http://nightmare.fun/adbtool';
                if (await canLaunch(url)) {
                  await launch(
                    url,
                    forceSafariVC: false,
                    forceWebView: false,
                    // headers: <String, String>{'my_header_key': 'my_header_value'},
                  );
                } else {
                  throw 'Could not launch $url';
                }
                // http://nightmare.fun/adbtool
                // widget.onChange?.call(index);
              },
            ),
            _DrawerItem(
              groupValue: widget.index,
              title: 'ADB命令手册',
              onTap: (index) async {
                Navigator.of(context).push<HelpPage>(
                  MaterialPageRoute(
                    builder: (_) {
                      return HelpPage();
                    },
                  ),
                );
              },
            ),
            // Padding(
            //   padding: EdgeInsets.all(Dimens.gap_dp16),
            //   child: Text(
            //     '版本：${Config.version}',
            //     style: const TextStyle(
            //       // fontWeight: FontWeight.bold,
            //       color: Colors.grey,
            //     ),
            //   ),
            // ),
          ],
        ),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    Key key,
    this.title,
    this.onTap,
    this.value,
    this.groupValue,
    this.iconData,
  }) : super(key: key);
  final String title;
  final void Function(int index) onTap;
  final int value;
  final int groupValue;
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    final bool isChecked = value == groupValue;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.gap_dp8,
      ),
      child: Tooltip(
        message: title,
        child: InkWell(
          onTap: () => onTap(value),
          splashColor: Colors.transparent,
          borderRadius: BorderRadius.circular(Dimens.gap_dp12),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: Dimens.gap_dp44,
                width: Dimens.gap_dp44,
                decoration: isChecked
                    ? BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimens.gap_dp12),
                      )
                    : null,
                child: Icon(
                  iconData ?? Icons.open_in_new,
                  size: 18,
                  color: isChecked ? AppColors.accent : AppColors.fontTitle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
