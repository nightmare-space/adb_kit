import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/widget/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'overview/pages/overview_page.dart';

class LogPage extends StatefulWidget {
  const LogPage({Key? key}) : super(key: key);

  @override
  State createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  final ConfigController controller = Get.find();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      //TODO
    } else {}
    AppBar? appBar;
    if (ResponsiveBreakpoints.of(context).isPhone) {
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
        left: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 0.w),
          child: Column(
            children: [
              SizedBox(height: 8.w),
              Expanded(
                child: CardItem(
                  child: Responsive(
                    builder: (__, _) {
                      return const LoggerView();
                    },
                  ),
                ),
              ),
              SizedBox(height: 8.w),
            ],
          ),
        ),
      ),
    );
  }
}
