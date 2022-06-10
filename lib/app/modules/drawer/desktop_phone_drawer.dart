import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/config/custom.dart';
import 'package:adb_tool/config/font.dart';
import 'package:adb_tool/core/interface/adb_page.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/instance/page_manager.dart';
import 'package:adb_tool/global/widget/mac_safearea.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';

class DesktopPhoneDrawer extends StatefulWidget {
  const DesktopPhoneDrawer({
    Key key,
    this.onChanged,
    this.groupValue,
    this.width,
  }) : super(key: key);
  final void Function(Widget page) onChanged;
  final String groupValue;
  final double width;

  @override
  State createState() => _DesktopPhoneDrawerState();
}

class _DesktopPhoneDrawerState<T> extends State<DesktopPhoneDrawer> {
  ConfigController configController = Get.find();

  @override
  Widget build(BuildContext context) {
    final double width = widget.width;
    return Material(
      color: ResponsiveWrapper.of(context).isDesktop
          ? Theme.of(context).colorScheme.background.withOpacity(0.2)
          : Theme.of(context).colorScheme.background,
      borderRadius: BorderRadius.circular(16.w),
      child: OrientationBuilder(
        builder: (context, orientation) {
          return MacSafeArea(
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
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.w),
        if (Custom.drawerHeader != null) Custom.drawerHeader,
        for (ADBPage page in PageManager.instance.pages)
          if (page.isActive)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: InkWell(
                onTap: () {
                  Global().changeDrawerRoute(page.runtimeType.toString());
                  widget.onChanged(page.buildPage(context));
                },
                borderRadius: BorderRadius.circular(8.w),
                child: page.buildDrawer(context),
              ),
            ),
      ],
    );
  }
}

final ConfigController configController = Get.find();

class DrawerItem extends StatelessWidget {
  const DrawerItem({
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: 48.w,
          decoration: isChecked
              ? BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
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
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).colorScheme.onBackground,
                  ),
                  SizedBox(
                    width: Dimens.gap_dp8,
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: isChecked
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).colorScheme.onBackground,
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
