import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/routes/app_pages.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class DesktopPhoneDrawer extends StatefulWidget {
  const DesktopPhoneDrawer({
    Key key,
    this.onChanged,
    this.groupValue,
    this.width,
  }) : super(key: key);
  final void Function(String index) onChanged;
  final String groupValue;
  final double width;

  @override
  _DesktopPhoneDrawerState createState() => _DesktopPhoneDrawerState();
}

class _DesktopPhoneDrawerState<T> extends State<DesktopPhoneDrawer> {
  ConfigController configController = Get.find();

  @override
  Widget build(BuildContext context) {
    final double width = widget.width;
    return OrientationBuilder(
      builder: (context, orientation) {
        return Material(
          color: Colors.white,
          shape: Responsive.of(context).screenType != ScreenType.desktop
              ? RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(Dimens.gap_dp20),
                    bottomRight: Radius.circular(Dimens.gap_dp20),
                  ),
                )
              : null,
          child: SafeArea(
            child: SizedBox(
              width: width,
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
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: Dimens.gap_dp8,
                ),
                child: Text(
                  'ADB TOOL',
                  style: TextStyle(
                    fontSize: 26.w,
                    fontWeight: FontWeight.bold,
                    color: configController.primaryColor,
                  ),
                ),
              ),
            ),
            _DrawerItem(
              title: '主页',
              value: Routes.overview,
              groupValue: widget.groupValue,
              onTap: (index) {
                widget.onChanged?.call(index);
              },
              iconData: Icons.home,
            ),
            _DrawerItem(
              value: Routes.history,
              groupValue: widget.groupValue,
              title: '历史连接',
              iconData: Icons.history,
              onTap: (index) async {
                widget.onChanged?.call(index);
              },
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
            // _DrawerItem(
            //   title: '当前设备ip',
            //   onTap: () {},
            // ),
            if (GetPlatform.isAndroid)
              Column(
                children: [
                  _DrawerItem(
                    value: Routes.netDebug,
                    groupValue: widget.groupValue,
                    iconData: Icons.signal_wifi_4_bar,
                    title: '远程调试',
                    onTap: (index) {
                      Log.e(index);
                      widget.onChanged?.call(index);
                    },
                  ),
                ],
              ),
            if (GetPlatform.isAndroid)
              _DrawerItem(
                value: Routes.installToSystem,
                groupValue: widget.groupValue,
                title: '安装到系统',
                iconData: Icons.file_download,
                onTap: (index) {
                  widget.onChanged?.call(index);
                },
              ),
            _DrawerItem(
              value: Routes.terminal,
              groupValue: widget.groupValue,
              title: '终端模拟器',
              iconData: Icons.code,
              onTap: (index) {
                widget.onChanged?.call(index);
              },
            ),

            _DrawerItem(
              value: Routes.log,
              groupValue: widget.groupValue,
              title: '日志',
              iconData: Icons.pending_outlined,
              onTap: (index) async {
                widget.onChanged?.call(index);
              },
            ),
            _DrawerItem(
              value: Routes.setting,
              groupValue: widget.groupValue,
              title: '设置',
              iconData: Icons.settings,
              onTap: (index) async {
                widget.onChanged?.call(index);
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
      ],
    );
  }
}

final ConfigController configController = Get.find();

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
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: InkWell(
        onTap: () => onTap(value),
        canRequestFocus: false,
        onTapDown: (_) {
          Feedback.forLongPress(context);
        },
        splashColor: Colors.transparent,
        borderRadius: BorderRadius.circular(8.w),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 48.w,
              decoration: isChecked
                  ? BoxDecoration(
                      color: configController.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.w),
                    )
                  : null,
            ),
            SizedBox(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16.w,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        iconData ?? Icons.open_in_new,
                        size: 18.w,
                        color: isChecked
                            ? configController.primaryColor
                            : AppColors.fontTitle,
                      ),
                      SizedBox(
                        width: Dimens.gap_dp8,
                      ),
                      Text(
                        title,
                        style: TextStyle(
                          color: isChecked
                              ? configController.primaryColor
                              : AppColors.fontTitle,
                          fontSize: 14.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
