import 'package:adb_kit/app/controller/config_controller.dart';
import 'package:adb_kit/global/widget/card_item.dart';
import 'package:adb_kit/generated/l10n.dart';
import 'package:adb_kit/global/widget/menu_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

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
    if (ResponsiveBreakpoints.of(context).isMobile) {
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
      body: SafeAreaFix(
        child: Column(
          children: [
            Expanded(
              child: CardItem(
                child: Responsive(
                  builder: (__, _) {
                    return LoggerView(
                      fontSize: 11.w,
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 8.w),
          ],
        ),
      ),
    );
  }
}
