import 'package:adb_tool/config/settings.dart';
import 'package:adb_tool/global/widget/menu_button.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:settings/settings.dart';

import 'setting_ctl.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SettingController controller = Get.put(SettingController());
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        title: const Text('设置'),
        // systemOverlayStyle: OverlayStyle.dark,
        leading: Menubutton(
          scaffoldContext: context,
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (appBar != null) appBar,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w),
              child: Text(
                '常规',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.w,
                ),
              ),
            ),
            SizedBox(
              height: 8.w,
            ),
            Builder(builder: (context) {
              return SettingItem(
                onTap: () async {
                  await controller.changeServerPath(context);
                  // setState(() {});
                },
                title: 'Server Path（服务端路径）',
                subTitle: '适配部分设备\n没有/data/local/tmp权限的问题',
                suffix: ValueListenableBuilder(
                  valueListenable: Settings.serverPath.ob,
                  builder: (c, v, child) {
                    return Text(
                      Settings.serverPath.get,
                      style: TextStyle(
                        color: AppColors.fontColor,
                        fontSize: 18.w,
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}

class SettingItem extends StatefulWidget {
  const SettingItem({
    Key key,
    this.title,
    this.onTap,
    this.subTitle,
    this.suffix = const SizedBox(),
  }) : super(key: key);

  final String title;
  final String subTitle;
  final void Function() onTap;
  final Widget suffix;
  @override
  _SettingItemState createState() => _SettingItemState();
}

class _SettingItemState extends State<SettingItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 10.w,
          vertical: 4.w,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 64.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        // color: Theme.of(context).colorScheme.primaryVariant,
                        fontWeight: FontWeight.w400,
                        fontSize: 18.w,
                        // height: 1.0,
                      ),
                    ),
                    Builder(builder: (_) {
                      final String content = widget.subTitle;
                      if (content == null) {
                        return const SizedBox();
                      }
                      return Text(
                        content,
                        style: TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.w400,
                          // height: 1.0,
                          fontSize: 14.w,
                        ),
                      );
                    }),
                  ],
                ),
                widget.suffix,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
