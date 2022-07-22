import 'package:adb_tool/adb_tool.dart';
import 'package:adb_tool/app/controller/controller.dart';
import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:adb_tool/config/font.dart';
import 'package:adb_tool/global/pages/terminal.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

class AppStarter extends StatefulWidget {
  const AppStarter({
    Key key,
    this.entity,
  }) : super(key: key);

  final DevicesEntity entity;
  @override
  State<AppStarter> createState() => _AppStarterState();
}

class _AppStarterState extends State<AppStarter> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12.w,
      ),
      child: Column(
        children: [
          Wrap(
            spacing: 12.w,
            runSpacing: 10.w,
            runAlignment: WrapAlignment.start,
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              GestureWithScale(
                onTap: () {
                  String cmd =
                      'adb -s ${widget.entity.serial} shell sh /data/data/me.piebridge.brevent/brevent.sh\r';
                  Global().pty.writeString(cmd);
                  HapticFeedback.vibrate();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).surface3,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.w,
                  ),
                  child: Text(
                    '启动黑域',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.w,
                    ),
                  ),
                ),
              ),
              GestureWithScale(
                onTap: () {
                  String cmd =
                      'adb -s ${widget.entity.serial} shell sh /data/user/0/com.omarea.vtools/files/up.sh\r';
                  Global().pty.writeString(cmd);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).surface3,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.w,
                  ),
                  child: Text(
                    '启动scene',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.w,
                    ),
                  ),
                ),
              ),
              GestureWithScale(
                onTap: () {
                  String cmd =
                      'adb -s ${widget.entity.serial} shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh\r';
                  Global().pty.writeString(cmd);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).surface3,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.w,
                  ),
                  child: Text(
                    '启动shizuku',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.w,
                    ),
                  ),
                ),
              ),
              GestureWithScale(
                onTap: () {
                  String cmd =
                      'adb -s ${widget.entity.serial} shell sh /storage/emulated/0/Android/data/web1n.stopapp/files/starter.sh\r';
                  Global().pty.writeString(cmd);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).surface3,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.w,
                  ),
                  child: Text(
                    '启动小黑屋',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.w,
                    ),
                  ),
                ),
              ),
              GestureWithScale(
                onTap: () {
                  String cmd =
                      'adb -s ${widget.entity.serial} shell sh /sdcard/Android/data/com.catchingnow.icebox/files/start.sh\r';
                  Global().pty.writeString(cmd);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).surface3,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.w,
                  ),
                  child: Text(
                    '启动冰箱',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.w,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.w),
          CardItem(
            child: SizedBox(
              height: 300,
              child: Column(
                children: [
                  Row(
                    children: [
                      const ItemHeader(color: CandyColors.candyPink),
                      Text(
                        S.of(context).terminal,
                        style: TextStyle(
                          fontSize: Dimens.font_sp16,
                          fontWeight: bold,
                        ),
                      ),
                    ],
                  ),
                  const Expanded(
                    child: TerminalPage(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
