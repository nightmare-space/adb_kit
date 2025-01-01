import 'package:adb_kit/adb_kit.dart';
import 'package:adb_kit/app/modules/home/adaptive_entry.dart';
import 'package:adb_kit/config/custom.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'drawer.dart';

class DesktopPhoneDrawer extends StatefulWidget {
  const DesktopPhoneDrawer({
    super.key,
    this.onChanged,
    required this.groupValue,
    this.width,
  });
  final RouteCallback? onChanged;
  final String groupValue;
  final double? width;

  @override
  State createState() => _DesktopPhoneDrawerState();
}

class _DesktopPhoneDrawerState<T> extends State<DesktopPhoneDrawer> {
  ConfigController configController = Get.find();

  @override
  Widget build(BuildContext context) {
    final double? width = widget.width;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    Color surfaceColor = colorScheme.surface;
    return Material(
      color: ResponsiveBreakpoints.of(context).isDesktop ? surfaceColor.withAlpha(opacity02) : surfaceColor,
      borderRadius: BorderRadius.circular(16.w),
      child: OrientationBuilder(
        builder: (context, orientation) {
          return SafeArea(
            left: false,
            child: SizedBox(
              width: width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Builder(
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
                  if (personHeader != null)
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(
                              bottom: 12.w,
                              left: 12.w,
                              right: 12.w,
                            ),
                            child: personHeader!,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    List<DrawerItem> drawers = desktopPhoneDrawer(widget.groupValue);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.w),
        if (Custom.drawerHeader != null) Custom.drawerHeader!,
        for (DrawerItem drawer in drawers)
          Builder(
            builder: (context) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: InkWell(
                  onTap: () {
                    widget.onChanged?.call(drawer.value!);
                  },
                  borderRadius: BorderRadius.circular(8.w),
                  child: drawer,
                ),
              );
            },
          ),
      ],
    );
  }
}

final ConfigController configController = Get.find();

class DrawerItem extends StatelessWidget {
  const DrawerItem({
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 48.w,
          decoration: isChecked
              ? BoxDecoration(
                  color: Theme.of(context).primaryColor.withAlpha(opacity01),
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
                    color: isChecked ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                  ),
                  SizedBox(
                    width: Dimens.gap_dp8,
                  ),
                  Text(
                    title!,
                    style: TextStyle(
                      color: isChecked ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.onSurface,
                      fontSize: 14.w,
                      fontWeight: bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
