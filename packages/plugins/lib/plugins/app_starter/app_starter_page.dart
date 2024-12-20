import 'package:adb_kit/adb_kit.dart' as adbkit;
import 'package:adb_kit/app/controller/controller.dart';
import 'package:adb_kit/app/modules/overview/pages/overview_page.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/global/widget/item_header.dart';
import 'package:adb_kit/global/widget/xterm_wrapper.dart';
import 'package:adb_kit/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:global_repository/global_repository.dart';
import 'package:plugins/generated/intl.dart';

/// 用来激活一些app服务，例如黑域，scene等
class AppStarterPage extends StatefulWidget {
  const AppStarterPage({
    super.key,
    this.entity,
  });

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
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 8.w),
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

                    String cmd = 'adb -s ${widget.entity!.serial} shell sh /storage/emulated/0/Android/data/com.nightmare.sula/files/start.sh\n';
                    // String cmd = '$adb -s ${widget.entity!.serial} shell sh /storage/emulated/0/Android/data/com.nightmare.sula/files/sula_starter\r';
                    adbkit.Global().pty!.writeString(cmd);
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
                      '${adbkit.S.current.start} Sula',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16.w,
                      ),
                    ),
                  ),
                ),
                GestureWithScale(
                  onTap: () {
                    String cmd = 'adb -s ${widget.entity!.serial} shell sh /data/data/me.piebridge.brevent/brevent.sh\r';
                    adbkit.Global().pty!.writeString(cmd);
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
                      '${adbkit.S.current.start} 黑域',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16.w,
                      ),
                    ),
                  ),
                ),
                GestureWithScale(
                  onTap: () {
                    String cmd = 'adb -s ${widget.entity!.serial} shell sh /sdcard/Android/data/com.omarea.vtools/up.sh\r';
                    adbkit.Global().pty!.writeString(cmd);
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
                      '${adbkit.S.current.start} scene',
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
                    String cmd = 'adb -s ${widget.entity!.serial} shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh\n';
                    adbkit.Global().pty!.writeString(cmd);
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
                      '${adbkit.S.current.start} shizuku',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16.w,
                      ),
                    ),
                  ),
                ),
                GestureWithScale(
                  onTap: () {
                    String cmd = 'adb -s ${widget.entity!.serial} shell sh /storage/emulated/0/Android/data/web1n.stopapp/files/starter.sh\r';
                    adbkit.Global().pty!.writeString(cmd);
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
                      '${adbkit.S.current.start} 小黑屋',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16.w,
                      ),
                    ),
                  ),
                ),
                GestureWithScale(
                  onTap: () {
                    String cmd = 'adb -s ${widget.entity!.serial} shell sh /sdcard/Android/data/com.catchingnow.icebox/files/start.sh\r';
                    adbkit.Global().pty!.writeString(cmd);
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
                      '${adbkit.S.current.start} ${adbkit.S.current.iceBox}',
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
                          adbkit.S.current.terminal,
                          style: TextStyle(
                            fontSize: Dimens.font_sp16,
                            fontWeight: bold,
                          ),
                        ),
                      ],
                    ),
                    // TODO(lin):
                    // 新开一个终端，不与 adb_kit 耦合
                    // new terminal, not coupled with adb_kit
                    Expanded(
                      child: Material(
                        color: colorScheme.surface,
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(12.w),
                        child: XTermWrapper(
                          pseudoTerminal: adbkit.Global().pty,
                          terminal: adbkit.Global().terminal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
