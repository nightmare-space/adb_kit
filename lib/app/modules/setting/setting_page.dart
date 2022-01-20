import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:adb_tool/config/settings.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adb_tool/global/widget/menu_button.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:cyclop/cyclop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
  ConfigController configController = Get.find();

  Set<Color> swatches = Colors.primaries.map((e) => Color(e.value)).toSet();
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (appBar != null) appBar,
            SizedBox(height: 24.w),
            CardItem(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ItemHeader(color: CandyColors.candyPink),
                      Text(
                        '界面',
                        style: TextStyle(
                          fontSize: 16.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SettingItem(
                    title: '布局风格',
                    suffix: Material(
                      borderRadius: BorderRadius.circular(12.w),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          Container(
                            width: 100.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                            ),
                            child: Center(
                              child: Text(
                                '桌面',
                                style: TextStyle(
                                  color: AppColors.fontColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 100.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: Color(0xffe6e6e6),
                            ),
                            child: Center(
                              child: Text(
                                '平板',
                                style: TextStyle(
                                  color: AppColors.fontColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 100.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                            ),
                            child: Center(
                              child: Text(
                                '桌面',
                                style: TextStyle(
                                  color: AppColors.fontColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 100.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                            ),
                            child: Center(
                              child: Text(
                                '自适应',
                                style: TextStyle(
                                  color: AppColors.fontColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SettingItem(
                    title: '主题',
                    suffix: Material(
                      borderRadius: BorderRadius.circular(12.w),
                      clipBehavior: Clip.antiAlias,
                      child: Row(
                        children: [
                          Container(
                            width: 100.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                            ),
                            child: Center(
                              child: Text(
                                '暗黑模式',
                                style: TextStyle(
                                  color: AppColors.fontColor,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 100.w,
                            height: 40.w,
                            decoration: BoxDecoration(
                              color: Color(0xffe6e6e6),
                            ),
                            child: Center(
                              child: Text(
                                '浅色模式',
                                style: TextStyle(
                                  color: AppColors.fontColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SettingItem(
                    title: '主题色',
                    suffix: Container(
                      child: ColorButton(
                        key: Key('c1'),
                        color: configController.primaryColor,
                        config: ColorPickerConfig(enableEyePicker: true),
                        size: 40.w,
                        elevation: 1,
                        boxShape: BoxShape.rectangle, // default : circle
                        swatches: swatches,
                        onColorChanged: (value) {
                          configController.primaryColor = value;
                          configController.update();
                          setState(() {});
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.w),
            CardItem(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ItemHeader(color: CandyColors.candyBlue),
                      Text(
                        '其他',
                        style: TextStyle(
                          fontSize: 16.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                  SettingItem(
                    title: '自动发现并连接设备',
                    suffix: Switch(
                      value: true,
                      onChanged: (_) {},
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.w),
            CardItem(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ItemHeader(color: CandyColors.candyGreen),
                      Text(
                        '开发者设置',
                        style: TextStyle(
                          fontSize: 16.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SettingItem(
                    onTap: () async {},
                    title: '打开性能监控',
                    suffix: Switch.adaptive(
                      value: configController.showPerformanceOverlay,
                      onChanged: configController.showPerformanceOverlayChange,
                    ),
                  ),
                  SettingItem(
                    onTap: () async {},
                    title: '显示刷新区域',
                    suffix: Switch(
                      value: debugRepaintRainbowEnabled,
                      onChanged: (value) {
                        // debugPaintSizeEnabled = true; // 显示文字基准线
                        // debugPaintPointersEnabled = true; // 突出点击对象
                        // debugPaintLayerBordersEnabled = true; // 显示层级边界
                        debugRepaintRainbowEnabled = value; // 显示重绘
                        configController.update();
                        setState(() {});
                      },
                    ),
                  ),
                  SettingItem(
                    onTap: () async {},
                    title: '突出点击对象',
                    suffix: Switch(
                      value: debugPaintPointersEnabled,
                      onChanged: (value) {
                        // debugPaintSizeEnabled = true; // 显示文字基准线
                        // debugPaintPointersEnabled = true; // 突出点击对象
                        // debugPaintLayerBordersEnabled = true; // 显示层级边界
                        debugPaintPointersEnabled = value; // 显示重绘
                        configController.update();
                        setState(() {});
                      },
                    ),
                  ),
                  SettingItem(
                    onTap: () async {},
                    title: '显示文字基准线',
                    suffix: Switch(
                      value: debugPaintSizeEnabled,
                      onChanged: (value) {
                        // debugPaintSizeEnabled = true; // 显示文字基准线
                        // debugPaintPointersEnabled = true; // 突出点击对象
                        // debugPaintLayerBordersEnabled = true; // 显示层级边界
                        debugPaintSizeEnabled = value; // 显示重绘
                        configController.update();
                        setState(() {});
                      },
                    ),
                  ),
                  SettingItem(
                    onTap: () async {},
                    title: '显示层级边界',
                    suffix: Switch(
                      value: debugPaintLayerBordersEnabled,
                      onChanged: (value) {
                        debugPaintLayerBordersEnabled = value; // 显示重绘
                        configController.update();
                        setState(() {});
                      },
                    ),
                  ),
                  SettingItem(
                    onTap: () async {},
                    title: '显示组件语义',
                    suffix: Switch(
                      value: configController.showSemanticsDebugger,
                      onChanged: (value) {
                        configController.showSemanticsDebugger = value;
                        configController.update();
                        setState(() {});
                      },
                    ),
                  ),
                  SettingItem(
                    onTap: () async {},
                    title: '显示绘制网格',
                    suffix: Switch(
                      value: configController.debugShowMaterialGrid,
                      onChanged: (value) {
                        configController.debugShowMaterialGrid = value;
                        configController.update();
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingItem extends StatefulWidget {
  const SettingItem({
    Key key,
    this.title,
    this.onTap,
    this.subTitle = '',
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
      // highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: 4.w,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 56.w),
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
                    if (widget.subTitle.isNotEmpty)
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
