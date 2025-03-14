import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/global/widget/card_item.dart';
import 'package:adb_kit/app/modules/overview/pages/overview_page.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/config/settings.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/widget/menu_button.dart';
import 'package:adb_kit/global/widget/xliv-switch.dart';
import 'package:adb_kit/themes/theme.dart';
import 'package:adb_kit/utils/color_util.dart';
// import 'package:cyclop/cyclop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:settings/settings.dart';

import 'menu.dart';
import 'password_dialog.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with WidgetsBindingObserver {
  ConfigController cc = Get.find();
  // TODO Check
  // Set<Color> swatches = Colors.primaries.map((e) => Color(e.value)).toSet();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppBar? appBar;
    if (ResponsiveBreakpoints.of(context).isMobile) {
      appBar = AppBar(
        title: Text(S.of(context).settings),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        // systemOverlayStyle: OverlayStyle.dark,
        leading: cc.needShowMenuButton
            ? Padding(
                padding: const EdgeInsets.all(0.0),
                child: Menubutton(
                  scaffoldContext: context,
                ),
              )
            : null,
        // leadingWidth: 48.w,
      );
    }

    Color titleColor = Theme.of(context).colorScheme.onSurface.withAlpha(opacity06);
    return SafeAreaFix(
      child: SingleChildScrollView(
        controller: ScrollController(),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.only(bottom: 48.w),
        child: GetBuilder<ConfigController>(builder: (_) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (appBar != null) appBar,
              // if (configController.screenType != ScreenType.phone)
              //   SizedBox(
              //     height: 16.w,
              //   ),
              SizedBox(height: 8.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const ItemHeader(color: CandyColors.candyPink),
                    Text(
                      S.of(context).view,
                      style: TextStyle(fontSize: 14.w, fontWeight: bold, color: titleColor),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.w),
              CardItem(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 0.w),
                    SettingItem(
                      title: S.of(context).layout,
                      suffix: Builder(builder: (context) {
                        if (cc.screenType == ScreenType.phone || ResponsiveBreakpoints.of(context).isMobile) {
                          return Column(
                            children: [
                              SelectTab(
                                value: cc.screenType == null ? 3 : cc.screenType!.index,
                                children: [
                                  Text(S.of(context).desktop),
                                  Text(S.of(context).pad),
                                ],
                                onChanged: (value) {
                                  cc.changeScreenType(ScreenType.values[value]);
                                },
                              ),
                              SizedBox(height: 4.w),
                              SelectTab(
                                value: cc.screenType == null ? 1 : cc.screenType!.index - 2,
                                children: [
                                  Text(S.of(context).phone),
                                  Text(S.of(context).autoFit),
                                ],
                                onChanged: (value) {
                                  if (value == 1) {
                                    cc.changeScreenType(null);
                                    return;
                                  }
                                  cc.changeScreenType(
                                    ScreenType.values[value + 2],
                                  );
                                },
                              ),
                            ],
                          );
                        }
                        return SelectTab(
                          value: cc.screenType == null ? 3 : cc.screenType!.index,
                          children: [
                            Text(S.of(context).desktop),
                            Text(S.of(context).pad),
                            Text(S.of(context).phone),
                            Text(S.of(context).autoFit),
                          ],
                          onChanged: (value) {
                            if (value == 3) {
                              cc.changeScreenType(null);
                              return;
                            }
                            cc.changeScreenType(ScreenType.values[value]);
                          },
                        );
                      }),
                    ),
                    GetBuilder<ConfigController>(builder: (_) {
                      return SettingItem(
                        title: S.of(context).theme,
                        suffix: SelectTab(
                          value: cc.themeMode.index,
                          onChanged: cc.changeTheme,
                          children: [
                            Text(S.of(context).system),
                            Text(S.of(context).light),
                            Text(S.of(context).dark),
                          ],
                        ),
                      );
                    }),
                    SettingItem(
                      title: S.of(context).language,
                      suffix: SelectTab(
                        value: cc.locale == ConfigController.english ? 1 : 0,
                        children: const [
                          Text('中文'),
                          Text('English'),
                        ],
                        onChanged: (value) {
                          if (value == 0) {
                            Get.locale = ConfigController.chinese;
                            cc.changeLocal(
                              ConfigController.chinese,
                            );
                          } else {
                            Get.locale = ConfigController.english;
                            cc.changeLocal(
                              ConfigController.english,
                            );
                          }
                        },
                      ),
                    ),
                    // SettingItem(
                    //   title: S.of(context).primaryColor,
                    //   suffix: ColorButton(
                    //     key: const Key('c1'),
                    //     color: Theme.of(context).primaryColor,
                    //     config:
                    //         const ColorPickerConfig(enableEyePicker: true),
                    //     size: 40.w,
                    //     elevation: 0,
                    //     boxShape: BoxShape.circle, // default : circle
                    //     swatches: swatches,
                    //     onColorChanged: (value) {
                    //       configController.update();
                    //       setState(() {});
                    //       Get.forceAppUpdate();
                    //     },
                    //   ),
                    // ),
                    GetBuilder<ConfigController>(builder: (_) {
                      return SettingItem(
                        title: S.of(context).showStatusBar,
                        suffix: AquaSwitch(
                          activeColor: Theme.of(context).primaryColor,
                          value: cc.showStatusBar,
                          onChanged: cc.changeStatusBarState,
                        ),
                      );
                    }),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(
                    //     horizontal: 8.0,
                    //   ),
                    //   child: Text(
                    //     '背景风格',
                    //     style: TextStyle(
                    //       // color: Theme.of(context).colorScheme.primaryVariant,
                    //       fontWeight: FontWeight.w400,
                    //       fontSize: 18.w,
                    //       // height: 1.0,
                    //     ),
                    //   ),
                    // ),
                    // SettingItem(
                    //   title: '背景风格',
                    //   suffix: SelectTab(
                    //     value: configController.backgroundStyle.index,
                    //     children: const [
                    //       Text('默认'),
                    //       Text('背景模糊'),
                    //       Text('全透明'),
                    //     ],
                    //     onChanged: (value) {
                    //       configController.changeBackgroundStyle(
                    //         BackgroundStyle.values[value],
                    //       );
                    //     },
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(height: 16.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      S.of(context).other,
                      style: TextStyle(fontSize: 14.w, fontWeight: bold, color: titleColor),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.w),
              CardItem(
                child: Column(
                  children: [
                    Builder(builder: (context) {
                      return SettingItem(
                        onTap: () async {
                          await cc.changeServerPath(context);
                          // setState(() {});
                        },
                        title: S.of(context).serverPath,
                        subTitle: S.of(context).fixDeviceWithoutDataLocalPermission,
                        suffix: ValueListenableBuilder(
                          valueListenable: Settings.serverPath.setting.ob,
                          builder: (c, dynamic v, child) {
                            return Text(
                              Settings.serverPath.setting.get(),
                              style: TextStyle(
                                fontSize: 16.w,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      );
                    }),
                    Builder(builder: (context) {
                      return SettingItem(
                        onTap: () async {
                          Get.dialog(const PasswordDialog());
                        },
                        title: 'ADB Password',
                        subTitle: 'Some device will need password when adb cmd execute',
                        suffix: Text(cc.password ?? ''),
                      );
                    }),
                    GetBuilder<ConfigController>(builder: (_) {
                      return SettingItem(
                        title: S.of(context).autoConnectDevice,
                        suffix: AquaSwitch(
                          activeColor: Theme.of(context).primaryColor,
                          value: cc.autoConnect,
                          onChanged: cc.changeAutoConnectState,
                        ),
                      );
                    }),
                    Builder(
                      builder: (context) {
                        return GetBuilder<ConfigController>(
                          builder: (_) {
                            return SettingItem(
                              title: S.current.fileSelecterType,
                              subTitle: S.current.fileSelecterTypeDes,
                              onTap: () async {
                                String result = await NiMenu.show(
                                  items: [
                                    NiMenyItem(
                                      value: FileSelecterType.custom.name,
                                      title: FileSelecterType.custom.nameIntl,
                                    ),
                                    NiMenyItem(
                                      value: FileSelecterType.saf.name,
                                      title: FileSelecterType.saf.nameIntl,
                                    ),
                                  ],
                                  context: context,
                                );
                                Log.i('result -> $result');
                                cc.changeFileSelecterType(FileSelecterType.values.byName(result));
                              },
                              suffix: SizedBox(
                                width: 100.w,
                                child: Text(
                                  cc.fileSelecterType.name,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    fontSize: 16.w,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.w),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // const ItemHeader(color: CandyColors.candyGreen),
                    Text(
                      S.of(context).developerSettings,
                      style: TextStyle(fontSize: 14.w, fontWeight: bold, color: titleColor),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.w),
              CardItem(
                child: Column(
                  children: [
                    SettingItem(
                      onTap: () async {},
                      title: S.of(context).showPerformanceOverlay,
                      suffix: AquaSwitch(
                        value: cc.showPerformanceOverlay,
                        onChanged: cc.showPerformanceOverlayChange,
                      ),
                    ),
                    SettingItem(
                      onTap: () async {},
                      title: S.of(context).debugRepaintRainbowEnabled,
                      suffix: AquaSwitch(
                        value: debugRepaintRainbowEnabled,
                        onChanged: (value) {
                          // debugPaintSizeEnabled = true; // 显示文字基准线
                          // debugPaintPointersEnabled = true; // 突出点击对象
                          // debugPaintLayerBordersEnabled = true; // 显示层级边界
                          debugRepaintRainbowEnabled = value; // 显示重绘
                          cc.update();
                          setState(() {});
                        },
                      ),
                    ),
                    SettingItem(
                      onTap: () async {},
                      title: S.of(context).debugPaintPointersEnabled,
                      suffix: AquaSwitch(
                        value: debugPaintPointersEnabled,
                        onChanged: (value) {
                          debugPaintPointersEnabled = value; // 显示重绘
                          cc.update();
                          setState(() {});
                        },
                      ),
                    ),
                    SettingItem(
                      onTap: () async {},
                      title: S.of(context).debugPaintSizeEnabled,
                      suffix: AquaSwitch(
                        value: debugPaintSizeEnabled,
                        onChanged: (value) {
                          debugPaintSizeEnabled = value; // 显示重绘
                          cc.update();
                          setState(() {});
                        },
                      ),
                    ),
                    SettingItem(
                      onTap: () async {},
                      title: S.of(context).debugPaintLayerBordersEnabled,
                      suffix: AquaSwitch(
                        value: debugPaintLayerBordersEnabled,
                        onChanged: (value) {
                          debugPaintLayerBordersEnabled = value; // 显示重绘
                          cc.update();
                          setState(() {});
                        },
                      ),
                    ),
                    SettingItem(
                      onTap: () async {},
                      title: S.of(context).showSemanticsDebugger,
                      suffix: AquaSwitch(
                        value: cc.showSemanticsDebugger,
                        onChanged: (value) {
                          cc.showSemanticsDebugger = value;
                          cc.update();
                          setState(() {});
                        },
                      ),
                    ),
                    SettingItem(
                      onTap: () async {},
                      title: S.of(context).debugShowMaterialGrid,
                      suffix: AquaSwitch(
                        value: cc.debugShowMaterialGrid,
                        onChanged: (value) {
                          cc.debugShowMaterialGrid = value;
                          cc.update();
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class SettingItem extends StatefulWidget {
  const SettingItem({
    super.key,
    this.title,
    this.onTap,
    this.subTitle = '',
    this.suffix = const SizedBox(),
  });

  final String? title;
  final String subTitle;
  final void Function()? onTap;
  final Widget suffix;
  @override
  State createState() => _SettingItemState();
}

class _SettingItemState extends State<SettingItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      // highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 8.w),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: 56.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        widget.title!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.w400,
                          fontSize: 18.w,
                          // height: 1.0,
                        ),
                      ),
                      if (widget.subTitle.isNotEmpty)
                        Builder(builder: (_) {
                          final String content = widget.subTitle;
                          return Text(
                            content,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(opacity06),
                              fontWeight: FontWeight.w400,
                              // height: 1.0,
                              fontSize: 14.w,
                            ),
                          );
                        }),
                    ],
                  ),
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

class AquaSwitch extends StatelessWidget {
  final bool value;

  final ValueChanged<bool> onChanged;

  final Color? activeColor;

  final Color? unActiveColor;

  final Color? thumbColor;

  const AquaSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.unActiveColor,
    this.thumbColor,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.78,
      child: XlivSwitch(
        unActiveColor: unActiveColor ?? Theme.of(context).primaryColor.withAlpha((255.0 * 0.1).round()),
        activeColor: Theme.of(context).primaryColor,
        thumbColor: thumbColor,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class SelectTab extends StatefulWidget {
  const SelectTab({
    super.key,
    this.children = const [],
    required this.value,
    this.onChanged,
  });
  final List<Widget> children;
  final int value;
  final void Function(int value)? onChanged;

  @override
  State createState() => _SelectTabState();
}

class _SelectTabState extends State<SelectTab> {
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(12.w),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: Colors.transparent,
      child: DefaultTextStyle(
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14.w,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        child: Row(
          children: [
            for (int i = 0; i < widget.children.length; i++)
              Builder(builder: (context) {
                bool isSelect = i == widget.value;
                Color background = isSelect ? Theme.of(context).colorScheme.primary.withOpacity(0.2) : Theme.of(context).colorScheme.surfaceContainer;
                return GestureDetector(
                  onTap: () {
                    widget.onChanged?.call(i);
                    Feedback.wrapForLongPress(() {}, context);
                  },
                  child: Container(
                    width: 96.w,
                    height: 40.w,
                    decoration: BoxDecoration(color: background),
                    child: Center(child: widget.children[i]),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
