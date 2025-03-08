import 'dart:convert';
import 'package:adb_kit/adb_kit.dart' hide S;
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/global/widget/item_header.dart';
import 'package:adb_kit/global/widget/xterm_wrapper.dart';
import 'package:adb_kit/utils/color_util.dart';
import 'package:adb_kit/utils/terminal_utill.dart';
import 'package:animations/animations.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pty/flutter_pty.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import '../../generated/intl.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:window_manager/window_manager.dart';
import 'package:xterm/xterm.dart';
import 'dialog/push_file.dart';
import 'developer_item.dart';
import 'drag_drop.dart';
import 'package:file_manager/file_manager.dart';
import 'package:adb_util/adb_util_flutter.dart';
import '../../widget/i18n_wrapper.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key, required this.device});

  final ADBDevice device;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with WindowListener {
  Pty? adbShell;
  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w);
  Terminal terminal = Terminal();
  bool get isMobile => ResponsiveBreakpoints.of(context).isMobile;
  ADBDevice get device => widget.device;

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
    if (device is ADBDeviceFromDartAPI) {
      AndroidAPIServerStarter.startServerByDart(device as ADBDeviceFromDartAPI).then((value) {
        Log.i('AndroidAPIServerStarter -> $value');
        Get.put(value);
      });
    } else {
      AndroidAPIServerStarter.startServer(
        widget.device.serial,
        password: device.password,
      ).then((value) {
        Log.i('AndroidAPIServerStarter -> $value');
        Get.put(value);
      });
    }
    if (GetPlatform.isWindows) {
      adbShell = Pty.start(
        'cmd',
        arguments: ['/C', 'adb', '-s', widget.device.serial, 'shell'],
        environment: envir(),
        workingDirectory: '/',
      );
    } else if (GetPlatform.isIOS) {
      ADBDeviceFromDartAPI device = widget.device as ADBDeviceFromDartAPI;
      device.adbio.adbShellInteractive().then((value) {
        value.listen((event) {
          terminal.write(event);
        });
        terminal.onOutput = (event) {
          value.write(event);
        };
      });
    } else {
      adbShell = Pty.start(
        adb,
        arguments: ['-s', widget.device.serial, 'shell'],
        environment: envir(),
        workingDirectory: '/',
      );
    }
    Future.delayed(1.seconds, () {
      if (device.password != null && device.password!.isNotEmpty) {
        adbShell!.writeString('${device.password}\n');
      }
    });
    if (adbShell != null) {
      adbShell?.output.cast<List<int>>().transform(const Utf8Decoder()).listen(
        (event) {
          terminal.write(event);
        },
      );
      terminal.onOutput = (event) {
        adbShell?.writeString(event);
      };
    }
  }

  @override
  void dispose() {
    adbShell?.kill();
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
                        P.of(context).common_switch,
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
                        title: Text(P.current.display_touch),
                        init: () => device.getSystemBool(key: 'show_touches'),
                        onOpen: () {
                          device.setSystem(key: 'show_touches', value: '1');
                        },
                        onClose: () {
                          device.setSystem(key: 'show_touches', value: '0');
                        },
                      ),
                      DashboardSwitchItem(
                        title: Text(P.current.displayScreenPointer),
                        init: () => device.getSystemBool(key: 'pointer_location'),
                        onOpen: () {
                          device.setSystem(key: 'pointer_location', value: '1');
                        },
                        onClose: () {
                          device.setSystem(key: 'pointer_location', value: '0');
                        },
                      ),
                      DashboardSwitchItem(
                        title: Text(P.current.showLayoutboundary),
                        init: () => Future.value(false),
                        onOpen: () {
                          device.runShell('setprop debug.layout true');
                          device.runShell('service call activity 1599295570');
                        },
                        onClose: () {
                          device.runShell('setprop debug.layout false');
                          device.runShell('service call activity 1599295570');
                        },
                      ),
                      DashboardSwitchItem(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(P.of(context).remoteAdbDebug),
                                Text(
                                  device.isNetworkDevice ? '(${P.current.currentDebug}:${P.current.remoteDebugDes})' : '(${P.current.currentDebug}:usb)',
                                )
                              ],
                            ),
                            Text(
                              P.of(context).remoteDebuSwitchgDes,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface.withAlpha(opacity06),
                                fontSize: 12.w,
                              ),
                            ),
                          ],
                        ),
                        init: () async {
                          String port = await device.getProp(key: 'service.adb.tcp.port');
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
                        P.current.install_apk,
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
                      title: '${P.current.drop_tip}${P.current.select_tip}',
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
                        pushFileWithPaths(paths, installApk: true);
                      },
                      onPerform: (paths) async {
                        if (GetPlatform.isDesktop) {
                          pushFileWithPaths(paths, installApk: true);
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

  void pushFileWithPaths(List<String>? paths, {bool installApk = false}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AKI18nWrapper(
          child: PushFileDialog(
            device: device,
            paths: paths,
            installApk: installApk,
          ),
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
                        P.current.upload_file,
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
                      title: '${P.current.drop_tip}${P.current.select_tip}',
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
                      TerminalView(
                        terminal,
                        backgroundOpacity: 0,
                        keyboardType: TextInputType.name,
                        theme: GetPlatform.isAndroid ? android : theme,
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
                                      return TerminalView(
                                        terminal,
                                        backgroundOpacity: 0,
                                        keyboardType: TextInputType.name,
                                        theme: GetPlatform.isAndroid ? android : theme,
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
