import 'package:adb_kit/app/controller/devices_controller.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:adb_kit/global/instance/plugin_manager.dart';
import 'package:adb_kit/global/widget/pop_button.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart' hide TabController;
import 'package:plugins/file_manager/fm_plugin.dart';

class DeveloperTool extends StatefulWidget {
  const DeveloperTool({
    Key? key,
    this.entity,
    this.providerContext,
  }) : super(key: key);
  final DevicesEntity? entity;
  final BuildContext? providerContext;

  @override
  State createState() => _DeveloperToolState();
}

class _DeveloperToolState extends State<DeveloperTool> with SingleTickerProviderStateMixin {
  int value = 0;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: const PopButton(),
                ),
                Expanded(
                  child: AKTabBar<int>(
                    value: value,
                    groupValue: value,
                    children: [
                      for (var item in PluginManager.instance.pluginsMap.keys)
                        Builder(builder: (context) {
                          Pluggable plugin = PluginManager.instance.pluginsMap[item]!;
                          return Row(
                            children: [
                              Text(
                                plugin.name,
                              ),
                              if (plugin is FilePlugin)
                                Row(
                                  children: [
                                    SizedBox(width: 8.w),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.tertiary.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(4.w),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                                      child: Text('Beta', style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
                                    ),
                                  ],
                                ),
                            ],
                          );
                        }),
                    ],
                    onChanged: (index) {
                      Log.d('index $index');
                      value = index;
                      pageController.animateToPage(
                        index,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            Expanded(
              child: PageView(
                controller: pageController,
                children: [
                  for (var item in PluginManager.instance.pluginsMap.keys) PluginManager.instance.pluginsMap[item]!.buildWidget(context, widget.entity),
                ],
              ),
            ),
            // Expanded(
            //   child: PluginManager.instance.pluginsMap[PluginManager.instance.pluginsMap.keys.toList()[value]]!.buildWidget(context, widget.entity),
            // ),
          ],
        ),
      ),
    );
  }
}

class AKTabBar<T> extends StatefulWidget {
  const AKTabBar({
    super.key,
    required this.children,
    required this.groupValue,
    required this.value,
    this.onChanged,
  });
  final List<Widget> children;
  final T groupValue;
  final T value;
  final void Function(T index)? onChanged;

  @override
  State<AKTabBar<T>> createState() => _AKTabBarState<T>();
}

class _AKTabBarState<T> extends State<AKTabBar<T>> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < widget.children.length; i++)
            GestureDetector(
              onTap: () {
                widget.onChanged?.call(i as T);
              },
              child: Builder(builder: (context) {
                bool isSelect = widget.value == i;
                Color fontColor = isSelect ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
                  decoration: BoxDecoration(
                    color: isSelect ? fontColor.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  child: DefaultTextStyle.merge(
                    child: widget.children[i],
                    style: TextStyle(
                      color: fontColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14.w,
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }
}
