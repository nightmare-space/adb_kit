import 'package:adb_tool/app/controller/controller.dart';
import 'package:adb_tool/app/modules/otg_terminal.dart';
import 'package:adb_tool/app/modules/setting/setting_page.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:animations/animations.dart';
import 'package:file_selector/file_selector.dart';
import 'package:file_selector_nightmare/file_selector_nightmare.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:pseudo_terminal_utils/pseudo_terminal_utils.dart';
import 'package:termare_pty/termare_pty.dart';
import 'package:termare_view/termare_view.dart';

import 'dialog/install_apk.dart';
import 'dialog/push_file.dart';
import 'drag_drop.dart';
import 'implement/binadb_channel.dart';
import 'implement/otgadb_channel.dart';
import 'interface/adb_channel.dart';
import 'screenshot_page.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key key, this.entity}) : super(key: key);

  final DevicesEntity entity;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  PseudoTerminal adbShell;

  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w);
  ADBChannel adbChannel;
  TermareController adbShellController;

  double getCardWidth() {
    final ScreenType screenType = Responsive.of(context).screenType;
    switch (screenType) {
      case ScreenType.phone:
        return context.mediaQuerySize.width;
        break;
      case ScreenType.tablet:
        return context.mediaQuerySize.width / 2;
        break;
      case ScreenType.desktop:
        return context.mediaQuerySize.width / 2;
        break;
      default:
        return context.mediaQuerySize.width;
    }
  }

  double getMiddlePadding() {
    final ScreenType screenType = Responsive.of(context).screenType;
    if (screenType == ScreenType.phone) {
      return 8.w;
    }
    return 4.w;
  }

  @override
  void initState() {
    super.initState();
    if (!GetPlatform.isWindows) {
      adbShell = TerminalUtil.getShellTerminal(
        exec: 'adb',
        arguments: ['-s', widget.entity.serial, 'shell'],
      );
    }
    if (widget.entity.isOTG) {
      adbChannel = OTGADBChannel();
    } else {
      adbChannel = BinADBChannel(widget.entity.serial);
    }
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
          //             fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.bold,
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
          height: 230.w,
          child: Material(
            color: Theme.of(context).colorScheme.surface1,
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
                        '常用开关',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          height: 1.0,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  Column(
                    children: [
                      _DeveloperItem(
                        adbChannel: adbChannel,
                        serial: widget.entity.serial,
                        title: '显示点按操作反馈',
                        putKey: 'show_touches',
                      ),
                      _DeveloperItem(
                        adbChannel: adbChannel,
                        serial: widget.entity.serial,
                        title: '显示屏幕指针',
                        putKey: 'pointer_location',
                      ),
                      SwitchItem(
                        title: '打开布局边界',
                        onOpen: () {
                          adbChannel.execCmmand(
                            'adb -s ${widget.entity.serial} shell setprop debug.layout true',
                          );
                          adbChannel.execCmmand(
                            'adb -s ${widget.entity.serial} shell service call activity 1599295570',
                          );
                          return true;
                        },
                        onClose: () {
                          adbChannel.execCmmand(
                            'adb -s ${widget.entity.serial} shell setprop debug.layout false',
                          );
                          adbChannel.execCmmand(
                            'adb -s ${widget.entity.serial} shell service call activity 1599295570',
                          );
                          return false;
                        },
                      ),
                      _OpenRemoteDebug(
                        adbChannel: adbChannel,
                        serial: widget.entity.serial,
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
          color: Theme.of(context).colorScheme.surface1,
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
                        '安装APK',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
                      title: (GetPlatform.isDesktop ? '拖放到此或' : '') +
                          '点击按钮选择Apk进行安装',
                      onTap: () async {
                        if (GetPlatform.isAndroid) {
                          if (!await PermissionUtil.requestStorage()) {
                            return;
                          }
                        }
                        List<String> paths;
                        if (GetPlatform.isDesktop) {
                          paths = [];
                          final typeGroup = XTypeGroup(label: 'images');
                          final files =
                              await openFiles(acceptedTypeGroups: [typeGroup]);
                          if (files.isEmpty) {
                            return;
                          }
                          for (final XFile xFile in files) {
                            paths.add(xFile.path);
                          }
                        } else {
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

  void pushFileWithPaths(List<String> paths) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PushFileDialog(
          adbChannel: adbChannel,
          paths: paths,
        );
      },
    );
  }

  void installApkWithPaths(List<String> paths) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return InstallApkDialog(
          adbChannel: adbChannel,
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
          color: Theme.of(context).colorScheme.surface1,
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
                        '上传文件',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
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
                      title: (GetPlatform.isDesktop ? '拖放到此或' : '') +
                          '点击按钮选择文件进行上传',
                      onTap: () async {
                        if (GetPlatform.isAndroid) {
                          if (!await PermissionUtil.requestStorage()) {
                            return;
                          }
                        }
                        List<String> paths;
                        if (GetPlatform.isDesktop) {
                          paths = [];
                          final typeGroup = XTypeGroup(label: 'images');
                          final files =
                              await openFiles(acceptedTypeGroups: [typeGroup]);
                          if (files.isEmpty) {
                            return;
                          }
                          for (final XFile xFile in files) {
                            paths.add(xFile.path);
                          }
                        } else {
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
    adbShellController ??= TermareController(
      fontFamily: '${Config.flutterPackage}MenloforPowerline',
      theme: TermareStyles.macos.copyWith(
        backgroundColor: Colors.transparent,
      ),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: getCardWidth(),
      ),
      child: Padding(
        padding: EdgeInsets.only(right: 8.w, left: getMiddlePadding()),
        child: Material(
          color: Theme.of(context).colorScheme.surface1,
          borderRadius: BorderRadius.circular(12.w),
          child: SizedBox(
            height: 230.w,
            child: OpenContainer<String>(
              useRootNavigator: false,
              tappable: true,
              transitionType: ContainerTransitionType.fade,
              openBuilder: (BuildContext context, _) {
                return Stack(
                  children: [
                    TermarePty(
                      pseudoTerminal: TerminalUtil.getShellTerminal(
                        exec: 'adb',
                        arguments: ['-s', widget.entity.serial, 'shell'],
                      ),
                      controller: adbShellController,
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
                                  fontWeight: FontWeight.bold,
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
                                  color: Theme.of(context).colorScheme.surface2,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(4.w),
                                  child: Builder(builder: (context) {
                                    if (GetPlatform.isWindows) {
                                      return const SizedBox();
                                    }
                                    if (widget.entity.isOTG) {
                                      return const OTGTerminal();
                                    }
                                    return TermarePty(
                                      key: const Key('TermarePty'),
                                      pseudoTerminal: adbShell,
                                      controller: adbShellController,
                                    );
                                  }),
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

class _OpenRemoteDebug extends StatefulWidget {
  const _OpenRemoteDebug({
    Key key,
    this.serial,
    @required this.adbChannel,
  }) : super(key: key);
  final String serial;
  final ADBChannel adbChannel;
  @override
  __OpenRemoteDebugState createState() => __OpenRemoteDebugState();
}

class __OpenRemoteDebugState extends State<_OpenRemoteDebug> {
  bool isCheck = false;
  @override
  void initState() {
    super.initState();
    initCheckState();
  }

  Future<void> initCheckState() async {
    final String result = await widget.adbChannel.execCmmand(
      'adb -s ${widget.serial} shell getprop service.adb.tcp.port',
    );
    Log.w(result);
    if (result == '5555') {
      isCheck = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimens.gap_dp48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      '远程调试',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      isAddress(widget.serial) ? '(当前方式:远程)' : '(当前方式:usb)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                Text(
                  '无需root可让设备打开远程调试',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12.w,
                  ),
                ),
              ],
            ),
            AquaSwitch(
              value: isCheck,
              onChanged: (_) async {
                isCheck = !isCheck;
                final int value = isCheck ? 5555 : 0;
                // String result = await exec(
                //   'adb -s ${widget.serial} shell setprop service.adb.tcp.port $value\n'
                //   'adb -s ${widget.serial} shell stop adbd\n'
                //   'adb -s ${widget.serial} shell start adbd\n',
                // );
                // print(result);
                // String result;
                await widget.adbChannel.changeNetDebugStatus(value);
                // Log.v(result);
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }
}

class SwitchItem extends StatefulWidget {
  const SwitchItem({
    Key key,
    this.title,
    this.onOpen,
    this.onClose,
  }) : super(key: key);
  final String title;
  final bool Function() onOpen;
  final bool Function() onClose;
  @override
  _SwitchItemState createState() => _SwitchItemState();
}

class _SwitchItemState extends State<SwitchItem> {
  bool isCheck = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimens.gap_dp48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            AquaSwitch(
              value: isCheck,
              onChanged: (_) {
                if (isCheck) {
                  isCheck = widget.onClose();
                } else {
                  isCheck = widget.onOpen();
                }
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }
}

class _DeveloperItem extends StatefulWidget {
  const _DeveloperItem({
    Key key,
    this.title,
    this.serial,
    this.putKey,
    @required this.adbChannel,
  }) : super(key: key);
  final String title;
  final String serial;
  final String putKey;
  final ADBChannel adbChannel;
  @override
  __DeveloperItemState createState() => __DeveloperItemState();
}

class __DeveloperItemState extends State<_DeveloperItem> {
  bool isCheck = false;
  @override
  void initState() {
    super.initState();
    initCheckState();
  }

  Future<void> initCheckState() async {
    final String result = await widget.adbChannel.execCmmand(
      'adb -s ${widget.serial} shell settings get system ${widget.putKey}',
    );
    Log.w('result -> $result');
    if (result == '1') {
      isCheck = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: Dimens.gap_dp48,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            AquaSwitch(
              value: isCheck,
              onChanged: (_) {
                isCheck = !isCheck;
                final int value = isCheck ? 1 : 0;
                widget.adbChannel.execCmmand(
                  'adb -s ${widget.serial} shell settings put system ${widget.putKey} $value',
                );
                setState(() {});
              },
            )
          ],
        ),
      ),
    );
  }
}

class GestureWithScale extends StatefulWidget {
  const GestureWithScale({
    Key key,
    this.onTap,
    this.child,
  }) : super(key: key);
  final void Function() onTap;
  final Widget child;

  @override
  _GestureWithScaleState createState() => _GestureWithScaleState();
}

class _GestureWithScaleState extends State<GestureWithScale>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..scale(
          1.0 - animationController.value * 0.02,
        ),
      child: GestureDetector(
        onTap: () {
          if (widget.onTap == null) {
            return;
          }
          setState(() {});
          Feedback.forLongPress(context);
          Feedback.forTap(context);
          animationController.reverse();
          widget.onTap();
        },
        onTapDown: (_) {
          if (widget.onTap == null) {
            return;
          }
          animationController.forward();
          Feedback.forLongPress(context);
          setState(() {});
        },
        onTapCancel: () {
          if (widget.onTap == null) {
            return;
          }
          animationController.reverse();
          Feedback.forLongPress(context);
          Feedback.forTap(context);
          setState(() {});
        },
        child: widget.child,
      ),
    );
  }
}
