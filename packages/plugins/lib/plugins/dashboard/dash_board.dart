import 'dart:convert';
import 'package:adb_kit/adb_kit.dart' hide S;
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/global/widget/item_header.dart';
import 'package:adb_kit/global/widget/xterm_wrapper.dart';
import 'package:adb_kit/utils/terminal_utill.dart';
import 'package:adb_kit/utils/utils.dart';
import 'package:animations/animations.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:plugins/generated/intl.dart';
import 'package:plugins/generated/l10n.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xterm/xterm.dart';
import 'dialog/install_apk.dart';
import 'dialog/push_file.dart';
import 'developer_item.dart';
import 'drag_drop.dart';
import 'package:file_manager/file_manager.dart';
import 'package:adb_util/adb_util_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.device});

  final DevicesEntity device;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WindowListener {
  Pty? adbShell;
  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w);
  Terminal terminal = Terminal();
  bool get isMobile => ResponsiveBreakpoints.of(context).isMobile;
  DevicesEntity get device => widget.device;

  /// 获取卡片宽度，主要是做响应式适配的
  double getCardWidth() {
    ResponsiveBreakpointsData data = ResponsiveBreakpoints.of(context);
    if (data.isMobile) {
      return context.mediaQuerySize.width;
    } else if (data.isTablet) {
      return context.mediaQuerySize.width / 2;
    } else {
      return context.mediaQuerySize.width / 2;
    }
  }

  double getMiddlePadding() {
    ResponsiveBreakpointsData data = ResponsiveBreakpoints.of(context);
    if (data.isMobile) {
      return 8.w;
    }
    return 4.w;
  }

  @override
  void initState() {
    super.initState();
    AndroidAPIServerStarter.startServer(
      widget.device.serial,
      password: device.password,
    );
    if (GetPlatform.isWindows) {
      adbShell = Pty.start(
        'cmd',
        arguments: ['/C', 'adb', '-s', widget.device.serial, 'shell'],
        environment: envir(),
        workingDirectory: '/',
      );
    } else {
      adbShell = Pty.start(
        adb,
        arguments: ['-s', widget.device.serial, 'shell'],
        environment: envir(),
        workingDirectory: '/',
      );
    }
    if (device.password != null) {
      adbShell!.writeString('${device.password}\n');
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
  void onWindowClose() {
    adbShell!.kill();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 64.w),
      child: Column(
        children: [
          SizedBox(height: 8.w),
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

  // ConstrainedBox screenshotBox() {
  //   return ConstrainedBox(
  //     constraints: BoxConstraints(
  //       maxWidth: getCardWidth(),
  //     ),
  //     child: Padding(
  //       padding: EdgeInsets.only(right: 8.w, left: getMiddlePadding()),
  //       child: NiCardButton(
  //         margin: EdgeInsets.zero,
  //         child: SizedBox(
  //           child: Padding(
  //             padding: padding,
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.stretch,
  //               children: [
  //                 Row(
  //                   crossAxisAlignment: CrossAxisAlignment.center,
  //                   children: [
  //                     const ItemHeader(color: CandyColors.candyCyan),
  //                     Text(
  //                       S.current.screenshot,
  //                       style: TextStyle(
  //                         fontWeight: bold,
  //                         height: 1.0,
  //                         color: Theme.of(context).primaryColor,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(
  //                   height: 4.0,
  //                 ),
  //                 SizedBox(
  //                   height: 200.w,
  //                   child: ScreenshotPage(devicesEntity: widget.entity),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

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
                        S.of(context).common_switch,
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
                      DashboardSwitchItem(
                        title: Text(S.current.display_touch),
                        init: () => getSystemBool(
                          serial: device.serial,
                          key: 'show_touches',
                          password: device.password,
                        ),
                        onOpen: () {
                          setSystem(
                            serial: device.serial,
                            key: 'show_touches',
                            value: '1',
                            password: device.password,
                          );
                        },
                        onClose: () {
                          setSystem(
                            serial: device.serial,
                            key: 'show_touches',
                            value: '0',
                            password: device.password,
                          );
                        },
                      ),
                      DashboardSwitchItem(
                        title: Text(S.current.displayScreenPointer),
                        init: () => getSystemBool(
                          serial: device.serial,
                          key: 'pointer_location',
                          password: device.password,
                        ),
                        onOpen: () {
                          setSystem(
                            serial: device.serial,
                            key: 'pointer_location',
                            value: '1',
                            password: device.password,
                          );
                        },
                        onClose: () {
                          setSystem(
                            serial: device.serial,
                            key: 'pointer_location',
                            value: '0',
                            password: device.password,
                          );
                        },
                      ),
                      DashboardSwitchItem(
                        title: Text(S.current.showLayoutboundary),
                        init: () => Future.value(false),
                        onOpen: () {
                          asyncExec('$adb -s ${device.serial} shell setprop debug.layout true');
                          asyncExec('$adb -s ${device.serial} shell service call activity 1599295570');
                        },
                        onClose: () {
                          asyncExec('$adb -s ${device.serial} shell setprop debug.layout false');
                          asyncExec('$adb -s ${device.serial} shell service call activity 1599295570');
                        },
                      ),
                      DashboardSwitchItem(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(S.of(context).remoteAdbDebug),
                                Text(
                                  isAddress(device.serial) ? '(${S.current.currentDebug}:${S.current.remoteDebugDes})' : '(${S.current.currentDebug}:usb)',
                                )
                              ],
                            ),
                            Text(
                              S.of(context).remoteDebuSwitchgDes,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 12.w,
                              ),
                            ),
                          ],
                        ),
                        init: () async {
                          String port = await getProp(
                            serial: device.serial,
                            key: 'service.adb.tcp.port',
                            password: device.password,
                          );
                          // TODO 支持识别其他端口
                          return port == '5555';
                        },
                        onOpen: () async {
                          await asyncExec('adb -s ${device.serial} tcpip 5555');
                        },
                        onClose: () async {
                          await asyncExec('adb -s ${device.serial} usb');
                        },
                      ),
                    ],
                  ),
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
                        S.current.install_apk,
                        style: TextStyle(
                          fontWeight: bold,
                          height: 1.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.w),
                  SizedBox(
                    height: 200.w,
                    child: DropTargetContainer(
                      title: '${P.drop_tip}${P.select_tip}',
                      onTap: () async {
                        if (GetPlatform.isAndroid) {
                          PermissionStatus status = await Permission.manageExternalStorage.request();
                          Log.i('status -> $status');
                          if (!status.isGranted) {
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
                          paths = await FileManager.selectFile();
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
          serial: device.serial,
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
          serial: device.serial,
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
                        S.current.upload_file,
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
                      title: '${P.drop_tip}${P.select_tip}',
                      onTap: () async {
                        if (GetPlatform.isAndroid) {
                          PermissionStatus status = await Permission.manageExternalStorage.request();
                          Log.i('status -> $status');
                          if (!status.isGranted) {
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
                          paths = await FileManager.selectFile();
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
          borderRadius: BorderRadius.circular(12.w),
          child: SizedBox(
            height: isMobile ? 240.w : 230.w,
            child: OpenContainer<String>(
              useRootNavigator: false,
              tappable: true,
              transitionType: ContainerTransitionType.fade,
              openBuilder: (BuildContext context, _) {
                return Scaffold(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  body: Stack(
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
                  ),
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
                      SizedBox(height: 4.w),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (_, box) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4.w),
                              child: Container(
                                decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface),
                                child: Padding(
                                  padding: EdgeInsets.all(4.w),
                                  child: Builder(
                                    builder: (context) {
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
