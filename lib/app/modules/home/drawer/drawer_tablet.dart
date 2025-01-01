import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/app/modules/home/adaptive_entry.dart';
import 'package:adb_kit/app/modules/home/drawer/drawer.dart';
import 'package:adb_kit/app/routes/ripple_router.dart';
import 'package:adb_kit/config/custom.dart';
import 'package:adb_kit/config/settings.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:adb_kit/themes/theme.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:settings/settings.dart';

class TabletDrawer extends StatefulWidget {
  const TabletDrawer({
    super.key,
    this.onChanged,
    required this.route,
  });
  final RouteCallback? onChanged;
  final String route;

  @override
  State createState() => _TabletDrawerState();
}

class _TabletDrawerState extends State<TabletDrawer> {
  final ConfigController config = Get.find();

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        return Material(
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(Dimens.gap_dp20),
              bottomRight: Radius.circular(Dimens.gap_dp20),
            ),
          ),
          child: SafeArea(
            left: false,
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Builder(
                builder: (_) {
                  if (orientation == Orientation.portrait) {
                    return buildBody();
                  }
                  return SingleChildScrollView(
                    // physics: const NeverScrollableScrollPhysics(),
                    child: buildBody(),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Column buildBody() {
    List<TabletDrawerItem> drawers = tabletDrawer(widget.route);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.w),
        if (Custom.drawerHeader != null) Custom.drawerHeader!,
        for (TabletDrawerItem drawer in drawers)
          Builder(
            builder: (context) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8.w),
                  onTap: () {
                    widget.onChanged?.call(drawer.value!);
                  },
                  child: drawer,
                ),
              );
            },
          ),
        Builder(builder: (context) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: InkWell(
              borderRadius: BorderRadius.circular(8.w),
              onTap: () {
                ThemeData theme = light(primary: Theme.of(context).primaryColor);
                if (Theme.of(context).brightness == Brightness.light) {
                  theme = dark();
                }
                if (theme.brightness == Brightness.dark) {
                  Settings.theme.setting.set('dark');
                } else {
                  Settings.theme.setting.set('light');
                }
                ConfigController controller = Get.find();
                controller.theme = theme;
                Navigator.of(context).pushReplacement(
                  RippleRoute(
                    GetBuilder<ConfigController>(
                      builder: (context) {
                        return Theme(data: context.theme!, child: Global().rootWidget!);
                      },
                    ),
                    RouteConfig.fromContext(context),
                  ),
                );
              },
              child: TabletDrawerItem(
                groupValue: widget.route,
                title: S.current.switchTheme,
                iconData: Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
              ),
            ),
          );
        }),
      ],
    );
  }
}

class TabletDrawerItem extends StatelessWidget {
  const TabletDrawerItem({
    super.key,
    this.title,
    this.onTap,
    this.value,
    this.groupValue,
    this.iconData,
  });
  final String? title;
  final void Function(String value)? onTap;
  final String? value;
  final String? groupValue;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    final bool isChecked = value == groupValue;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Tooltip(
      message: title,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Container(
            height: 54.w,
            width: 54.w,
            decoration: isChecked
                ? BoxDecoration(
                    color: colorScheme.primary.withAlpha(opacity015),
                    borderRadius: BorderRadius.circular(12.w),
                  )
                : null,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData ?? Icons.open_in_new,
                  size: 24.w,
                  color: isChecked ? colorScheme.primary : colorScheme.onSurface,
                ),
                SizedBox(height: 4.w),
                // Text(
                //   title.substring(0, 2),
                //   style: TextStyle(
                //     height: 1.0,
                //     color: config.theme.fontColor,
                //     fontSize: 12.w,
                //     fontWeight: bold,
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
