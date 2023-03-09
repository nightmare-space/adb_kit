import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adb_tool/config/font.dart';
import 'package:adb_tool/global/instance/plugin_manager.dart';
import 'package:adb_tool/global/widget/pop_button.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart' hide TabController;

import 'tab_indicator.dart';

class DeveloperTool extends StatefulWidget {
  const DeveloperTool({Key? key, this.entity, this.providerContext})
      : super(key: key);
  final DevicesEntity? entity;
  final BuildContext? providerContext;
  @override
  State createState() => _DeveloperToolState();
}

class _DeveloperToolState extends State<DeveloperTool>
    with SingleTickerProviderStateMixin {
  TabController? controller;

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
    controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.background,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(48.w),
          child: SafeArea(
            left: false,
            child: Row(
              children: [
                SizedBox(
                  width: 8.w,
                ),
                const PopButton(),
                Expanded(
                  child: TabBar(
                    labelStyle: TextStyle(
                      fontWeight: bold,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontWeight: bold,
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
                        Tab(text: PluginManager.instance.pluginsMap[item]!.name),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: controller,
          children: [
            for (var item in PluginManager.instance.pluginsMap.keys)
              PluginManager.instance.pluginsMap[item]!
                  .buildWidget(context, widget.entity),
          ],
        ),
      ),
    );
  }
}
