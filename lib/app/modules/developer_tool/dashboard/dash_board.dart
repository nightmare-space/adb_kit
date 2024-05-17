import 'dart:convert';

import 'package:adb_kit/app/controller/controller.dart';
import 'package:adb_kit/app/modules/otg_terminal.dart';
import 'package:adb_kit/app/modules/setting/setting_page.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/widget/item_header.dart';
import 'package:adb_kit/global/widget/xterm_wrapper.dart';
import 'package:adb_kit/themes/theme.dart';
import 'package:adb_kit/utils/terminal_utill.dart';
import 'package:adbutil/adbutil.dart';
import 'package:animations/animations.dart';
import 'package:file_manager_view/file_manager_view.dart' hide execCmd;
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xterm/xterm.dart';
import '../dialog/install_apk.dart';
import '../dialog/push_file.dart';
import '../drag_drop.dart';
import '../screenshot_page.dart';
import 'developer_item.dart';
import 'network_debug.dart';
import 'switch_item.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key, this.entity}) : super(key: key);

  final DevicesEntity? entity;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WindowListener {
  Pty? adbShell;

  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w);
  Terminal terminal = Terminal();
  bool get isMobile => ResponsiveBreakpoints.of(context).isMobile;

  /// 获取卡片宽度，主要是做响应式适配的
  double getCardWidth() {
    ResponsiveBreakpointsData data = ResponsiveBreakpoints.of(context);
    if (data.isPhone) {
      return context.mediaQuerySize.width;
    } else if (data.isTablet) {
      return context.mediaQuerySize.width / 2;
    } else {
      return context.mediaQuerySize.width / 2;
    }
  }

  double getMiddlePadding() {
    ResponsiveBreakpointsData data = ResponsiveBreakpoints.of(context);
    if (data.isPhone) {
      return 8.w;
    }
    return 4.w;
  }

  @override
  void initState() {
    super.initState();
    if (GetPlatform.isWindows) {
      adbShell = Pty.start(
        'cmd',
        arguments: ['/C', 'adb', '-s', widget.entity!.serial, 'shell'],
        environment: envir() as Map<String, String>?,
        workingDirectory: '/',
      );
    } else {
      adbShell = Pty.start(
        adb,
        arguments: ['-s', widget.entity!.serial, 'shell'],
        environment: envir() as Map<String, String>?,
        workingDirectory: '/',
      );
    }
    adbShell!.output.cast<List<int>>().transform(const Utf8Decoder()).listen(
      (event) {
        terminal.write(event);
      },
    );
  }

  @override
  void dispose() {
    adbShell!.kill();
    super.dispose();
  }

  @override
  void onWindowEvent(String eventName) {
    Log.i('[WindowManager] onWindowEvent: $eventName');
  }

  @override
  void onWindowClose() {
    adbShell!.kill();
    // do something
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 64.w),
      child: Column(
        children: [
          Wrap(
            runSpacing: 8.w,
            children: [
              buildOptions(),
              buildTerminal(),
            ],
          ),
          SizedBox(height: 8.w),
          Wrap(
            runSpacing: 8.w,
            children: [
              installApkBox(),
              uploadFileBox(),
            ],
          ),
          SizedBox(height: 8.w),
          // screenshotBox(),
          // InkWell(
          //   onTap: () {
          //     adbChannel.execCmmand(
          //       'adb -s ${widget.entity.serial} shell settings put system handy_mode_state 1\n'
          //       'adb -s ${widget.entity.serial} shell settings put system handy_mode_size 5.5\n'
          //       'adb -s ${widget.entity.serial} shell am broadcast -a miui.action.handymode.changemode --ei mode 2\n',
          //     );
          //   },
          //   child: SizedBox(
          //     height: Dimens.gap_dp48,
          //     child: Padding(
          //       padding: EdgeInsets.symmetric(
          //         horizontal: Dimens.gap_dp12,
          //       ),
          //       child: const Align(
          //         alignment: Alignment.centerLeft,
          //         child: Text(
          //           '开启单手模式',
          //           style: TextStyle(
          //             fontWeight: bold,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  ConstrainedBox screenshotBox() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: getCardWidth(),
      ),
      child: Padding(
        padding: EdgeInsets.only(right: 8.w, left: getMiddlePadding()),
        child: NiCardButton(
          margin: EdgeInsets.zero,
          child: SizedBox(
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ItemHeader(color: CandyColors.candyCyan),
                      Text(
                        '屏幕截图',
                        style: TextStyle(
                          fontWeight: bold,
                          height: 1.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  SizedBox(
                    height: 200.w,
                    child: ScreenshotPage(
                      devicesEntity: widget.entity,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ConstrainedBox buildOptions() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: getCardWidth(),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8.w, right: getMiddlePadding()),
        child: SizedBox(
          height: isMobile ? 240.w : 230.w,
          child: Material(
            color: Theme.of(context).surface1,
            borderRadius: BorderRadius.circular(12.w),
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ItemHeader(color: CandyColors.candyPink),
                      Text(
                        S.of(context).commonSwitch,
                        style: TextStyle(
                          fontWeight: bold,
                          height: 1.0,
                          fontSize: 14.w,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.w),
                  Column(
                    children: [
                      DeveloperItem(
                        serial: widget.entity!.serial,
                        title: S.of(context).displayTouch,
                        putKey: 'show_touches',
                      ),
                      DeveloperItem(
                        serial: widget.entity!.serial,
                        title: S.of(context).displayScreenPointer,
                        putKey: 'pointer_location',
                      ),
                      SwitchItem(
                        title: S.of(context).showLayoutboundary,
                        onOpen: () {
                          execCmd(
                            'adb -s ${widget.entity!.serial} shell setprop debug.layout true',
                          );
                          execCmd(
                            'adb -s ${widget.entity!.serial} shell service call activity 1599295570',
                          );
                          return true;
                        },
                        onClose: () {
                          execCmd(
                            'adb -s ${widget.entity!.serial} shell setprop debug.layout false',
                          );
                          execCmd(
                            'adb -s ${widget.entity!.serial} shell service call activity 1599295570',
                          );
                          return false;
                        },
                      ),
                      NetworkDebug(
                        serial: widget.entity!.serial,
                      ),
                    ],
                  ),
                  // Row(
                  //   children: const <Widget>[
                  //     Text('标题'),
                  //     SizedBox(
                  //       width: 16.0,
                  //     ),
                  //     SizedBox(
                  //       width: 120,
                  //       child: TextField(
                  //         decoration: InputDecoration(
                  //           isDense: true,
                  //           // border: OutlineInputBorder(),
                  //           contentPadding: EdgeInsets.symmetric(
                  //             horizontal: 08.0,
                  //             vertical: 8.0,
                  //           ),
                  //         ),
                  //       ),
                  //     )
                  //   ],
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ConstrainedBox installApkBox() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: getCardWidth(),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: 8.w, right: getMiddlePadding()),
        child: Material(
          color: Theme.of(context).surface1,
          borderRadius: BorderRadius.circular(12.w),
          child: SizedBox(
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ItemHeader(color: CandyColors.candyBlue),
                      Text(
                        S.of(context).installApk,
                        style: TextStyle(
                          fontWeight: bold,
                          height: 1.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  SizedBox(
                    height: 200.w,
                    child: DropTargetContainer(
                      title: '${GetPlatform.isDesktop ? '拖放到此或' : ''}${S.of(context).pushTips}',
                      onTap: () async {
                        if (GetPlatform.isAndroid) {
                          if (!await PermissionUtil.requestStorage()) {
                            return;
                          }
                        }
                        List<String>? paths;
                        if (GetPlatform.isDesktop) {
                          paths = [];
                          const typeGroup = XTypeGroup(
                            label: 'apk',
                            extensions: ['apk'],
                          );
                          final files = await openFiles(acceptedTypeGroups: [typeGroup]);
                          if (files.isEmpty) {
                            return;
                          }
                          for (final XFile xFile in files) {
                            paths.add(xFile.path);
                          }
                        } else {
                          // ignore: use_build_context_synchronously
                          paths = await FileSelector.pick(context);
                        }
                        if (paths.isEmpty) {
                          return;
                        }
                        installApkWithPaths(paths);
                      },
                      onPerform: (paths) async {
                        if (GetPlatform.isDesktop) {
                          installApkWithPaths(paths);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void pushFileWithPaths(List<String>? paths) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PushFileDialog(
          entity: widget.entity!,
          paths: paths,
        );
      },
    );
  }

  void installApkWithPaths(List<String>? paths) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return InstallApkDialog(
          entity: widget.entity!,
          paths: paths,
        );
      },
    );
  }

  ConstrainedBox uploadFileBox() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: getCardWidth(),
      ),
      child: Padding(
        padding: EdgeInsets.only(right: 8.w, left: getMiddlePadding()),
        child: Material(
          color: Theme.of(context).surface1,
          borderRadius: BorderRadius.circular(12.w),
          child: SizedBox(
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const ItemHeader(color: CandyColors.candyCyan),
                      Text(
                        S.of(context).uploadFile,
                        style: TextStyle(
                          fontWeight: bold,
                          height: 1.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  SizedBox(
                    height: 200.w,
                    child: DropTargetContainer(
                      title: '${GetPlatform.isDesktop ? '拖放到此或' : ''}${S.of(context).pushTips}',
                      onTap: () async {
                        if (GetPlatform.isAndroid) {
                          if (!await PermissionUtil.requestStorage()) {
                            return;
                          }
                        }
                        List<String>? paths;
                        if (GetPlatform.isDesktop) {
                          paths = [];
                          const typeGroup = XTypeGroup(label: '*');
                          final files = await openFiles(acceptedTypeGroups: [typeGroup]);
                          if (files.isEmpty) {
                            return;
                          }
                          for (final XFile xFile in files) {
                            paths.add(xFile.path);
                          }
                        } else {
                          // ignore: use_build_context_synchronously
                          paths = await FileSelector.pick(context);
                        }
                        if (paths.isEmpty) {
                          return;
                        }
                        pushFileWithPaths(paths);
                      },
                      onPerform: (paths) async {
                        if (GetPlatform.isDesktop) {
                          pushFileWithPaths(paths);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ConstrainedBox buildTerminal() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: getCardWidth(),
      ),
      child: Padding(
        padding: EdgeInsets.only(right: 8.w, left: getMiddlePadding()),
        child: Material(
          color: Theme.of(context).surface1,
          borderRadius: BorderRadius.circular(12.w),
          child: SizedBox(
            height: isMobile ? 240.w : 230.w,
            child: OpenContainer<String>(
              useRootNavigator: false,
              tappable: true,
              transitionType: ContainerTransitionType.fade,
              openBuilder: (BuildContext context, _) {
                return Stack(
                  children: [
                    XTermWrapper(
                      terminal: terminal,
                      pseudoTerminal: adbShell,
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureWithScale(
                        onTap: () {
                          Get.back();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.fullscreen_exit,
                            size: 24.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              transitionDuration: const Duration(milliseconds: 300),
              openColor: Colors.transparent,
              closedElevation: 0.0,
              openElevation: 0.0,
              closedColor: Colors.transparent,
              closedBuilder: (
                BuildContext context,
                VoidCallback openContainer,
              ) {
                return Padding(
                  padding: padding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const ItemHeader(color: CandyColors.candyGreen),
                              Text(
                                'SHELL',
                                style: TextStyle(
                                  height: 1.0,
                                  fontWeight: bold,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ),
                            ],
                          ),
                          GestureWithScale(
                            onTap: () {
                              openContainer();
                            },
                            child: const Icon(Icons.fullscreen),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4.w,
                      ),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (_, box) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4.w),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).surface2,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(4.w),
                                  child: Builder(
                                    builder: (context) {
                                      if (widget.entity!.isOTG) {
                                        return const OTGTerminal();
                                      }
                                      return XTermWrapper(
                                        terminal: terminal,
                                        pseudoTerminal: adbShell,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
