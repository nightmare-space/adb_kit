import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/app/routes/ripple_router.dart';
import 'package:adb_kit/config/custom.dart';
import 'package:adb_kit/config/settings.dart';
import 'package:adb_kit/core/interface/adb_page.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/instance/global.dart';
import 'package:adb_kit/global/instance/page_manager.dart';
import 'package:adb_kit/themes/app_colors.dart';
import 'package:adb_kit/themes/theme.dart';
import 'package:adb_kit/themes/theme_dark.dart';
import 'package:adb_kit/themes/theme_light.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:settings/settings.dart';

class TabletDrawer extends StatefulWidget {
  const TabletDrawer({
    Key? key,
    this.onChanged,
    this.groupValue,
  }) : super(key: key);
  final void Function(Widget page)? onChanged;
  final String? groupValue;

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
                    return buildBody(context);
                  }
                  return SingleChildScrollView(
                    // physics: const NeverScrollableScrollPhysics(),
                    child: buildBody(context),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.w),
        if (Custom.drawerHeader != null) Custom.drawerHeader!,
        for (ADBPage page in PageManager.instance!.pages)
          if (page.isActive)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: InkWell(
                borderRadius: BorderRadius.circular(8.w),
                onTap: () {
                  Global().changeDrawerRoute(page.runtimeType.toString());
                  widget.onChanged!(page.buildPage(context));
                },
                child: page.buildTabletDrawer(context),
              ),
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
                groupValue: widget.groupValue,
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
    Key? key,
    this.title,
    this.onTap,
    this.value,
    this.groupValue,
    this.iconData,
  }) : super(key: key);
  final String? title;
  final void Function(String value)? onTap;
  final String? value;
  final String? groupValue;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    final bool isChecked = value == groupValue;
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
                  color: isChecked ? AppColors.accent : Theme.of(context).colorScheme.onBackground,
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
