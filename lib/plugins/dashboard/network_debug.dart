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
    final String result = await execCmd(
      '$adb -s ${widget.serial} shell getprop service.adb.tcp.port',
    );
    // Log.w(result);
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
    return InkWell(
      onTap: () {},
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 48.w,
          maxHeight: 140.w,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: isMobile ? 54.w : 48.w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 200.w, minWidth: 10.w),
                        child: Text(
                          S.of(context).remoteDebuSwitchgDes,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                            fontSize: 12.w,
                          ),
                        ),
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
                  // String result = await exec(
                  //   'adb -s ${widget.serial} shell setprop service.adb.tcp.port $value\n'
                  //   'adb -s ${widget.serial} shell stop adbd\n'
                  //   'adb -s ${widget.serial} shell start adbd\n',
                  // );
                  // print(result);
                  // String result;
                  int port = value;
                  if (port == 5555) {
                    await execCmd(
                      '$adb -s ${widget.serial} tcpip 5555',
                    );
                  } else {
                    await execCmd(
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
