import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/app/modules/setting/setting_page.dart';
import 'package:adb_tool/app/modules/wrappers/app_launcher_wrapper.dart';
import 'package:adb_tool/app/modules/wrappers/app_manager_wrapper.dart';
import 'package:adb_tool/app/modules/developer_tool/drag_drop.dart';
import 'package:adb_tool/app/modules/developer_tool/interface/adb_channel.dart';
import 'package:adb_tool/app/modules/developer_tool/implement/binadb_channel.dart';
import 'package:adb_tool/app/modules/developer_tool/implement/otgadb_channel.dart';
import 'package:adb_tool/app/modules/otg_terminal.dart';
import 'package:adb_tool/app/modules/wrappers/device_info_wrapper.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/global/instance/plugin_manager.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adb_tool/global/widget/pop_button.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:animations/animations.dart';
import 'package:device_info/device_info.dart' hide RoundedUnderlineTabIndicator;
import 'package:file_selector/file_selector.dart';
import 'package:file_selector_nightmare/file_selector_nightmare.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:pseudo_terminal_utils/pseudo_terminal_utils.dart';
import 'package:termare_pty/termare_pty.dart';
import 'package:termare_view/termare_view.dart';

import 'app_starter.dart';
import 'dialog/install_apk.dart';
import 'dialog/push_file.dart';
import 'screenshot_page.dart';
import 'tab_indicator.dart';
import 'task_manager.dart';

class DeveloperTool extends StatefulWidget {
  const DeveloperTool({Key key, this.entity, this.providerContext})
      : super(key: key);
  final DevicesEntity entity;
  final BuildContext providerContext;
  @override
  _DeveloperToolState createState() => _DeveloperToolState();
}

class _DeveloperToolState extends State<DeveloperTool>
    with SingleTickerProviderStateMixin {
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: PluginManager.instance.pluginsMap.length,
      vsync: this,
    );
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return TitlebarSafeArea(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48.w),
          child: SafeArea(
            child: Row(
              children: [
                SizedBox(
                  width: 8.w,
                ),
                const PopButton(),
                Expanded(
                  child: TabBar(
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelColor: AppColors.fontColor,
                    indicator: RoundedUnderlineTabIndicator(
                      insets: EdgeInsets.only(bottom: 12.w),
                      radius: 12.w,
                      // width: 50.w,
                      borderSide: BorderSide(
                        width: 4.w,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      // color: Color(0xff6002ee),
                      // borderRadius: BorderRadius.only(
                      //     topLeft: Radius.circular(25), topRight: Radius.circular(25)),
                    ),
                    labelPadding: EdgeInsets.symmetric(horizontal: 10.w),
                    isScrollable: true,
                    controller: controller,
                    tabs: <Widget>[
                      for (var item in PluginManager.instance.pluginsMap.keys)
                        Tab(text: PluginManager.instance.pluginsMap[item].name),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TitlebarSafeArea(
          child: TabBarView(
            controller: controller,
            children: [
              for (var item in PluginManager.instance.pluginsMap.keys)
                PluginManager.instance.pluginsMap[item]
                    .buildWidget(context, widget.entity),
            ],
          ),
        ),
      ),
    );
  }
}
