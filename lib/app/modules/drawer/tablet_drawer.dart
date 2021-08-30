import 'dart:io';
import 'package:adb_tool/app/routes/app_pages.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:url_launcher/url_launcher.dart';


class TabletDrawer extends StatefulWidget {
  const TabletDrawer({
    Key key,
    this.onChanged,
    this.groupValue,
  }) : super(key: key);
  final void Function(String index) onChanged;
  final String groupValue;

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
              title: '面板',
              value: Routes.overview,
              groupValue: widget.groupValue,
              onTap: (value) {
                widget.onChanged.call(value);
              },
              iconData: Icons.home,
            ),
            if (!kIsWeb && Platform.isAndroid)
              Column(
                children: [
                  _DrawerItem(
                    value: Routes.netDebug,
                    groupValue: widget.groupValue,
                    iconData: Icons.signal_wifi_4_bar,
                    title: '远程调试',
                    onTap: (value) {
                      widget.onChanged.call(value);
                    },
                  ),
                  _DrawerItem(
                    value: Routes.searchIp,
                    groupValue: widget.groupValue,
                    title: '查看局域网ip',
                    onTap: (value) {
                      widget.onChanged.call(value);
                    },
                    iconData: Icons.wifi_tethering,
                  ),
                ],
              ),
            // _DrawerItem(
            //   title: '连接设备',
            //   value: 1,
            //   groupValue: widget.groupValue,
            //   onTap: (index) {
            //     widget.onChanged?.call(index);
            //   },
            //   iconData: Icons.data_saver_off,
            // ),
            if (!kIsWeb && Platform.isAndroid)
              _DrawerItem(
                value: Routes.installToSystem,
                groupValue: widget.groupValue,
                title: '安装到系统',
                iconData: Icons.file_download,
                onTap: (value) {
                  Log.e(value);
                  widget.onChanged.call(value);
                },
              ),
            // _DrawerItem(
            //   title: '当前设备ip',
            //   onTap: () {},
            // ),

            _DrawerItem(
              value: Routes.terminal,
              groupValue: widget.groupValue,
              title: '终端模拟器',
              iconData: Icons.code,
              onTap: (value) {
                widget.onChanged.call(value);
              },
            ),

            _DrawerItem(
              value: Routes.history,
              groupValue: widget.groupValue,
              title: '历史连接',
              iconData: Icons.history,
              onTap: (value) {
                widget.onChanged.call(value);
              },
            ),
            _DrawerItem(
              value: Routes.log,
              groupValue: widget.groupValue,
              title: '日志',
              iconData: Icons.pending_outlined,
              onTap: (value) {
                widget.onChanged.call(value);
              },
            ),
            _DrawerItem(
              value: Routes.about,
              groupValue: widget.groupValue,
              title: '关于软件',
              iconData: Icons.info_outline,
              onTap: (index) async {
                widget.onChanged?.call(index);
              },
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DrawerItem(
              groupValue: widget.groupValue,
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
  final void Function(String value) onTap;
  final String value;
  final String groupValue;
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
          onTapDown: (_) {
            Feedback.forLongPress(context);
          },
          onTap: () => onTap(value),
          splashColor: Colors.transparent,
          borderRadius: BorderRadius.circular(Dimens.gap_dp12),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: Dimens.gap_dp54,
                width: Dimens.gap_dp54,
                decoration: isChecked
                    ? BoxDecoration(
                        color: AppColors.accent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(Dimens.gap_dp12),
                      )
                    : null,
                child: Icon(
                  iconData ?? Icons.open_in_new,
                  size: 24.w,
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
