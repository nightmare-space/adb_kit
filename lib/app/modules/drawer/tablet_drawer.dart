import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/modules/home/views/adaptive_view.dart';
import 'package:adb_tool/app/routes/ripple_router.dart';
import 'package:adb_tool/config/settings.dart';
import 'package:adb_tool/core/interface/adb_page.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/instance/page_manager.dart';
import 'package:adb_tool/global/widget/mac_safearea.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:settings/settings.dart';

class TabletDrawer extends StatefulWidget {
  const TabletDrawer({
    Key key,
    this.onChanged,
    this.groupValue,
  }) : super(key: key);
  final void Function(Widget page) onChanged;
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
          color: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(Dimens.gap_dp20),
              bottomRight: Radius.circular(Dimens.gap_dp20),
            ),
          ),
          child: MacSafeArea(
            child: SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Builder(
                  builder: (_) {
                    if (orientation == Orientation.portrait) {
                      return buildBody(context);
                    }
                    return SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: buildBody(context),
                    );
                  },
                ),
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
        SizedBox(
          height: 8.w,
        ),
        for (ADBPage page in PageManager.instance.pages)
          if (page.isActive)
            page.buildTabletDrawer(context, () {
              Global().changeDrawerRoute(page.runtimeType.toString());
              widget.onChanged(page.buildPage(context));
            }),
        Builder(builder: (context) {
          return TabletDrawerItem(
            groupValue: widget.groupValue,
            title: '切换主题',
            iconData: Theme.of(context).brightness == Brightness.dark
                ? Icons.light_mode
                : Icons.dark_mode,
            onTap: (value) {
              ThemeData theme = DefaultThemeData.light(
                primary: Theme.of(context).primaryColor,
              );
              if (Theme.of(context).brightness == Brightness.light) {
                theme = DefaultThemeData.dark();
              }
              if (theme.brightness == Brightness.dark) {
                Settings.theme.set = 'dark';
              } else {
                Settings.theme.set = 'light';
              }
              ConfigController controller = Get.find();
              controller.theme = theme;
              Navigator.of(context).pushReplacement(
                RippleRoute(
                  GetBuilder<ConfigController>(
                    builder: (context) {
                      return Theme(
                        data: context.theme,
                        child: Stack(
                          children: [
                            GetBuilder<ConfigController>(builder: (_) {
                              if (config.backgroundStyle ==
                                  BackgroundStyle.normal) {
                                return Container(
                                  color: theme.colorScheme.background,
                                );
                              }
                              if (config.backgroundStyle ==
                                  BackgroundStyle.image) {
                                return SizedBox(
                                  height: double.infinity,
                                  child: Image.asset(
                                    'assets/b.png',
                                    fit: BoxFit.cover,
                                  ),
                                );
                              } else {
                                return const SizedBox();
                              }
                            }),
                            const AdbTool(),
                          ],
                        ),
                      );
                    },
                  ),
                  RouteConfig.fromContext(context),
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

class TabletDrawerItem extends StatelessWidget {
  const TabletDrawerItem({
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
                      color: isChecked
                          ? AppColors.accent
                          : Theme.of(context).colorScheme.onBackground,
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
