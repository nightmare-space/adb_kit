import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/widget/menu_button.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:termare_view/termare_view.dart';

import 'overview/pages/overview_page.dart';

class LogPage extends StatefulWidget {
  const LogPage({Key key}) : super(key: key);

  @override
  _LogPageState createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final ConfigController controller = Get.find();
  bool verbose = true;
  bool debug = true;
  bool info = true;
  bool warning = true;
  bool error = true;

  @override
  void initState() {
    super.initState();
  }

  void onChange() {
    Global().logTerminalCTL.clear();
    Log.buffer.forEach((v) {
      final String data =
          '[${twoDigits(v.time.hour)}:${twoDigits(v.time.minute)}:${twoDigits(v.time.second)}] ${v.data}';
      if (v.level == LogLevel.verbose && verbose) {
        Global().logTerminalCTL.write(data + "\r\n");
      }
      if (v.level == LogLevel.debug && debug) {
        Global().logTerminalCTL.write(data + "\r\n");
      }
      if (v.level == LogLevel.info && info) {
        Global().logTerminalCTL.write(data + "\r\n");
      }
      if (v.level == LogLevel.warning && warning) {
        Global().logTerminalCTL.write(data + "\r\n");
      }
      if (v.level == LogLevel.error && error) {
        Global().logTerminalCTL.write(data + "\r\n");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (configController.isDarkTheme) {
      Global().logTerminalCTL.theme = TermareStyles.vsCode.copyWith(
        backgroundColor: Theme.of(context).cardColor,
        fontSize: 11.w,
      );
    } else {
      Global().logTerminalCTL.theme = TermareStyles.macos.copyWith(
        backgroundColor: Theme.of(context).cardColor,
        fontSize: 11.w,
      );
    }
    AppBar appBar;
    if (Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        title: Text(S.of(context).log),
        automaticallyImplyLeading: false,
        leading: controller.needShowMenuButton
            ? Menubutton(
                scaffoldContext: context,
              )
            : null,
      );
    }
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.w),
          child: Column(
            children: [
              WrapContainerList(
                children: [
                  CheckContainer(
                    value: verbose,
                    data: 'verbose',
                    onChanged: (value) {
                      verbose = value;
                      setState(() {});
                      onChange();
                    },
                  ),
                  CheckContainer(
                    value: debug,
                    data: 'debug',
                    onChanged: (value) {
                      debug = value;
                      setState(() {});
                      onChange();
                    },
                  ),
                  CheckContainer(
                    value: info,
                    data: 'info',
                    onChanged: (value) {
                      info = value;
                      setState(() {});
                      onChange();
                    },
                  ),
                  CheckContainer(
                    value: warning,
                    data: 'warning',
                    onChanged: (value) {
                      warning = value;
                      setState(() {});
                      onChange();
                    },
                  ),
                  CheckContainer(
                    value: error,
                    data: 'error',
                    onChanged: (value) {
                      error = value;
                      setState(() {});
                      onChange();
                    },
                  ),
                ],
              ),
              SizedBox(height: 8.w),
              Expanded(
                child: CardItem(
                  child: TermareView(
                    controller: Global().logTerminalCTL,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckContainer extends StatelessWidget {
  const CheckContainer({
    Key key,
    this.onChanged,
    this.value,
    this.data,
  }) : super(key: key);

  final void Function(bool value) onChanged;
  final bool value;
  final String data;

  @override
  Widget build(BuildContext context) {
    final ConfigController controller = Get.find();
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.w),
        border: Border.all(
          color: Colors.transparent,
          width: 2.w,
        ),
      ),
      child: GestureWithScale(
        onTap: () {
          onChanged(!value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: value
                ? Theme.of(context).primaryColor
                : controller.theme.grey.shade200,
            borderRadius: BorderRadius.circular(8.w),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
              child: Text(
                data,
                style: TextStyle(
                  color: value ? Colors.white : AppColors.fontColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

typedef ChangeCall<T> = void Function(T value);
