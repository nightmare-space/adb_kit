import 'package:adb_kit/app/modules/setting/setting_page.dart';
import 'package:adb_kit/config/font.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adbutil/adbutil.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';

class NetworkDebug extends StatefulWidget {
  const NetworkDebug({
    Key? key,
    this.serial,
  }) : super(key: key);
  final String? serial;
  @override
  State createState() => _NetworkDebugState();
}

class _NetworkDebugState extends State<NetworkDebug> {
  bool isCheck = false;
  @override
  void initState() {
    super.initState();
    initCheckState();
  }

  Future<void> initCheckState() async {
    final String result = await asyncExec('$adb -s ${widget.serial} shell getprop service.adb.tcp.port');
    if (result == '5555') {
      isCheck = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = ResponsiveBreakpoints.of(context).isMobile;
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {},
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 48.w),
        child: SizedBox(
          height: isMobile ? 48.w : 48.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          S.of(context).remoteAdbDebug,
                          style: TextStyle(
                            fontWeight: bold,
                            fontSize: 16.w,
                          ),
                        ),
                        Text(
                          isAddress(widget.serial!) ? '(${S.current.currentDebug}:${S.current.remoteDebugDes})' : '(${S.current.currentDebug}:usb)',
                          style: TextStyle(
                            fontWeight: bold,
                            color: colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      S.of(context).remoteDebuSwitchgDes,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: 12.w,
                      ),
                    ),
                  ],
                ),
              ),
              AquaSwitch(
                value: isCheck,
                onChanged: (_) async {
                  isCheck = !isCheck;
                  final int value = isCheck ? 5555 : 0;
                  int port = value;
                  if (port == 5555) {
                    await asyncExec(
                      '$adb -s ${widget.serial} tcpip 5555',
                    );
                  } else {
                    await asyncExec(
                      '$adb -s ${widget.serial} usb',
                    );
                  }
                  // Log.v(result);
                  setState(() {});
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
