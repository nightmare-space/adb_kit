import 'dart:io';
import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/modules/home/views/home_view.dart';
import 'package:adb_tool/app/routes/app_pages.dart';
import 'package:adb_tool/app/routes/ripple_router.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

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
  final ConfigController config = Get.find();

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Material(
          color: config.theme.cardColor,
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
              title: S.of(context).home,
              value: Routes.overview,
              groupValue: widget.groupValue,
              onTap: (value) {
                widget.onChanged.call(value);
              },
              iconData: Icons.home,
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
            if (!kIsWeb && Platform.isAndroid)
              _DrawerItem(
                value: Routes.netDebug,
                groupValue: widget.groupValue,
                iconData: Icons.signal_wifi_4_bar,
                title: S.of(context).networkDebug,
                onTap: (value) {
                  widget.onChanged.call(value);
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
            if (!kIsWeb && Platform.isAndroid)
              _DrawerItem(
                value: Routes.installToSystem,
                groupValue: widget.groupValue,
                title: '安装到系统',
                iconData: Icons.file_download,
                onTap: (value) {
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
              value: Routes.log,
              groupValue: widget.groupValue,
              title: S.of(context).log,
              iconData: Icons.pending_outlined,
              onTap: (value) async {
                widget.onChanged.call(value);
              },
            ),
            _DrawerItem(
              value: Routes.setting,
              groupValue: widget.groupValue,
              title: S.of(context).settings,
              iconData: Icons.settings,
              onTap: (index) async {
                widget.onChanged?.call(index);
              },
            ),
            _DrawerItem(
              value: Routes.about,
              groupValue: widget.groupValue,
              title: S.of(context).about,
              iconData: Icons.info_outline,
              onTap: (index) async {
                widget.onChanged?.call(index);
              },
            ),
            Builder(builder: (context) {
              return _DrawerItem(
                groupValue: widget.groupValue,
                title: '切换主题',
                iconData:
                    config.isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                onTap: (value) {
                  if (config.isDarkTheme) {
                    config.theme = LightTheme();
                  } else {
                    config.theme = DarkTheme();
                  }
                  final ThemeData theme = DefaultThemeData.light(
                    primary: config.primaryColor,
                  );
                  Navigator.of(context).pushReplacement(
                    RippleRoute(
                        Theme(
                          data: theme,
                          child: AdbTool(
                            initRoute: widget.groupValue,
                          ),
                        ),
                        RouteConfig.fromContext(context)),
                  );
                },
              );
            }),
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
    final ConfigController config = Get.find();
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
          canRequestFocus: false,
          onTap: () => onTap(value),
          splashColor: Colors.transparent,
          borderRadius: BorderRadius.circular(Dimens.gap_dp12),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 54.w,
                width: 54.w,
                decoration: isChecked
                    ? BoxDecoration(
                        color: AppColors.accent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.w),
                      )
                    : null,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData ?? Icons.open_in_new,
                      size: 24.w,
                      color:
                          isChecked ? AppColors.accent : config.theme.fontColor,
                    ),
                    SizedBox(height: 4.w),
                    // Text(
                    //   title.substring(0, 2),
                    //   style: TextStyle(
                    //     height: 1.0,
                    //     color: config.theme.fontColor,
                    //     fontSize: 12.w,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
