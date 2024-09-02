import 'package:adb_kit/adb_tool.dart';
import 'package:adb_kit/app/controller/controller.dart';
import 'package:adb_kit/app/modules/overview/pages/overview_page.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/global/pages/terminal.dart';
import 'package:adb_kit/global/widget/item_header.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';

/// 用来激活一些app服务，例如黑域，scene等
class AppStarterPage extends StatefulWidget {
  const AppStarterPage({
    Key? key,
    this.entity,
  }) : super(key: key);

  final DevicesEntity? entity;
  @override
  State<AppStarterPage> createState() => _AppStarterPageState();
}

class _AppStarterPageState extends State<AppStarterPage> {
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
                  // adb shell sh /storage/emulated/0/Android/data/com.nightmare.sula/files/sula_starter
                  String cmd = '$adb -s ${widget.entity!.serial} shell sh /storage/emulated/0/Android/data/com.nightmare.sula/files/sula_starter\r';
                  Global().pty!.writeString(cmd);
                  HapticFeedback.vibrate();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.w,
                  ),
                  child: Text(
                    '${S.current.start} Sula',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16.w,
                    ),
                  ),
                ),
              ),
              GestureWithScale(
                onTap: () {
                  String cmd = '$adb -s ${widget.entity!.serial} shell sh /data/data/me.piebridge.brevent/brevent.sh\r';
                  Global().pty!.writeString(cmd);
                  HapticFeedback.vibrate();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.w,
                  ),
                  child: Text(
                    '${S.current.start} 黑域',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16.w,
                    ),
                  ),
                ),
              ),
              GestureWithScale(
                onTap: () {
                  String cmd = '$adb -s ${widget.entity!.serial} shell sh /sdcard/Android/data/com.omarea.vtools/up.sh\r';
                  Global().pty!.writeString(cmd);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.w,
                  ),
                  child: Text(
                    '${S.current.start} scene',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16.w,
                    ),
                  ),
                ),
              ),
              GestureWithScale(
                onTap: () {
                  // adb shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh
                  String cmd = '$adb -s ${widget.entity!.serial} shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh\n';
                  Global().pty!.writeString(cmd);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.w,
                  ),
                  child: Text(
                    '${S.current.start} shizuku',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16.w,
                    ),
                  ),
                ),
              ),
              GestureWithScale(
                onTap: () {
                  String cmd = '$adb -s ${widget.entity!.serial} shell sh /storage/emulated/0/Android/data/web1n.stopapp/files/starter.sh\r';
                  Global().pty!.writeString(cmd);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.w,
                  ),
                  child: Text(
                    '${S.current.start} 小黑屋',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16.w,
                    ),
                  ),
                ),
              ),
              GestureWithScale(
                onTap: () {
                  String cmd = '$adb -s ${widget.entity!.serial} shell sh /sdcard/Android/data/com.catchingnow.icebox/files/start.sh\r';
                  Global().pty!.writeString(cmd);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12.w),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 8.w,
                  ),
                  child: Text(
                    '${S.current.start} ${S.current.iceBox}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
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
              height: 400.w,
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
