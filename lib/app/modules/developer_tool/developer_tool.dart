import 'package:adb_tool/app/modules/drag_drop.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/widget/pop_button.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:global_repository/global_repository.dart';
import 'package:pseudo_terminal_utils/pseudo_terminal_utils.dart';
import 'package:termare_pty/termare_pty.dart';
import 'package:termare_view/termare_view.dart';
import 'install_apk_page.dart.dart';
import 'upload_file.dart';

class DeveloperTool extends StatefulWidget {
  const DeveloperTool({Key key, this.serial, this.providerContext})
      : super(key: key);
  final String serial;
  final BuildContext providerContext;
  @override
  _DeveloperToolState createState() => _DeveloperToolState();
}

class _DeveloperToolState extends State<DeveloperTool> {
  EdgeInsets padding = EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.w);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          widget.serial,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyText2.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: const PopButton(),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Wrap(
              runSpacing: 8.w,
              children: [
                buildOptions(),
                buildTerminal(),
              ],
            ),
            SizedBox(
              height: 12.w,
            ),
            Wrap(
              runSpacing: 8.w,
              children: [
                uploadFileBox(),
                uploadFileBox(),
              ],
            ),
            InkWell(
              onTap: () {
                exec(
                  'adb -s ${widget.serial} shell settings put system handy_mode_state 1\n'
                  'adb -s ${widget.serial} shell settings put system handy_mode_size 5.5\n'
                  'adb -s ${widget.serial} shell am broadcast -a miui.action.handymode.changemode --ei mode 2\n',
                );
              },
              child: SizedBox(
                height: Dimens.gap_dp48,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimens.gap_dp12,
                  ),
                  child: const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '开启单手模式',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ConstrainedBox buildOptions() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 414.w,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: NiCardButton(
          margin: EdgeInsets.zero,
          child: SizedBox(
            child: Padding(
              padding: padding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '常用开关',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  Column(
                    children: [
                      _DeveloperItem(
                        serial: widget.serial,
                        title: '显示点按操作反馈',
                        putKey: 'show_touches',
                      ),
                      _DeveloperItem(
                        serial: widget.serial,
                        title: '开启单手模式',
                        putKey: 'handy_mode_state',
                      ),
                      _DeveloperItem(
                        serial: widget.serial,
                        title: '显示屏幕指针',
                        putKey: 'pointer_location',
                      ),
                      _OpenRemoteDebug(
                        serial: widget.serial,
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

  ConstrainedBox uploadFileBox() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 414.w,
      ),
      child: NiCardButton(
        margin: EdgeInsets.zero,
        child: SizedBox(
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '上传文件',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(
                  height: 4.0,
                ),
                SizedBox(
                  height: 300,
                  child: DragDropPage(),
                ),
                // Container(
                //   height: 100.w,
                //   width: double.infinity,
                //   decoration: BoxDecoration(
                //     color: AppColors.background,
                //     borderRadius: BorderRadius.circular(4.w),
                //   ),
                //   child: Center(
                //     child: Text(
                //       '拖拽上传',
                //       style: TextStyle(
                //         color: AppColors.fontColor.withOpacity(0.6),
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ConstrainedBox buildTerminal() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: 414.w,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        child: NiCardButton(
          margin: EdgeInsets.zero,
          child: SizedBox(
            child: Padding(
              padding: padding,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SHELL',
                    style: TextStyle(
                      height: 1.0,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(
                    height: 4.0,
                  ),
                  LayoutBuilder(
                    builder: (_, box) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                          ),
                          height: 200,
                          child: Padding(
                            padding: EdgeInsets.all(4.w),
                            child: TermarePty(
                              pseudoTerminal: TerminalUtil.getShellTerminal(
                                useIsolate: false,
                                exec: 'adb',
                                arguments: ['-s', widget.serial, 'shell'],
                              ),
                              controller: TermareController(
                                fontFamily:
                                    '${Config.flutterPackage}MenloforPowerline',
                                theme: TermareStyles.macos.copyWith(
                                  backgroundColor: AppColors.background,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Expanded(
                  //   child: TermarePty(
                  //     pseudoTerminal: TerminalUtil.getShellTerminal(useIsolate: false),
                  //   ),
                  // ),
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
}

class _OpenRemoteDebug extends StatefulWidget {
  const _OpenRemoteDebug({
    Key key,
    this.serial,
  }) : super(key: key);
  final String serial;
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
    final String result = await exec(
      'adb -s ${widget.serial} shell getprop service.adb.tcp.port',
    );
    print(result);
    if (result == '5555') {
      isCheck = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
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
            Switch(
              value: isCheck,
              onChanged: (_) async {
                isCheck = !isCheck;
                final int value = isCheck ? 5555 : -1;
                // String result = await exec(
                //   'adb -s ${widget.serial} shell setprop service.adb.tcp.port $value\n'
                //   'adb -s ${widget.serial} shell stop adbd\n'
                //   'adb -s ${widget.serial} shell start adbd\n',
                // );
                // print(result);
                String result;
                if (isCheck) {
                  result = await exec(
                    'adb -s ${widget.serial} shell setprop service.adb.tcp.port $value\n'
                    'adb -s ${widget.serial} tcpip 5555',
                  );
                } else {
                  result = await exec(
                    'adb -s ${widget.serial} shell setprop service.adb.tcp.port $value\n'
                    'adb -s ${widget.serial} usb',
                  );
                }
                print(result);
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
    this.putType,
  }) : super(key: key);
  final String title;
  final String serial;
  final String putKey;
  final String putType;
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
    final String result = await exec(
      'adb -s ${widget.serial} shell settings get system ${widget.putKey}',
    );
    if (result == '1') {
      isCheck = true;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        margin: EdgeInsets.symmetric(
            // horizontal: Dimens.gap_dp12,
            ),
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
            Switch(
              value: isCheck,
              onChanged: (_) {
                isCheck = !isCheck;
                final int value = isCheck ? 1 : 0;
                print(
                    'adb -s ${widget.serial} shell settings put system show_touches 1');
                exec(
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
