import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:adb_tool/config/font.dart';
import 'package:adb_tool/generated/l10n.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/pages/terminal.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide ScreenType;
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';

// 安装 adb 工具到系统
class AdbInstallToSystemPage extends StatefulWidget {
  const AdbInstallToSystemPage({Key? key}) : super(key: key);

  @override
  State createState() => _AdbInstallToSystemPageState();
}

class _AdbInstallToSystemPageState extends State<AdbInstallToSystemPage> {
  String binPath = '/system/bin';
  String xbinPath = '/system/xbin';
  String? choosePath;

  final ConfigController controller = Get.find();

  @override
  void initState() {
    super.initState();
    choosePath = xbinPath;
  }

  @override
  Widget build(BuildContext context) {
    AppBar? appBar;
    if (ResponsiveWrapper.of(context).isPhone ||
        controller.screenType == ScreenType.phone) {
      appBar = AppBar(
        title: Text(S.of(context).installToSystem),
        automaticallyImplyLeading: false,
        leading: controller.needShowMenuButton
            ? IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              )
            : null,
      );
    }
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
        left: false,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.gap_dp8,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CardItem(
                      child: Column(
                        children: [
                          Row(
                            children: <Widget>[
                              const ItemHeader(
                                color: CandyColors.candyCyan,
                              ),
                              Text(
                                S.of(context).chooseInstallPath,
                                style: TextStyle(
                                  fontSize: 16.w,
                                  fontWeight: bold,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    xbinPath,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: bold,
                                    ),
                                  ),
                                  Radio(
                                    value: xbinPath,
                                    groupValue: choosePath,
                                    onChanged: (String? value) {
                                      choosePath = value;
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    binPath,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: bold,
                                    ),
                                  ),
                                  Radio<String>(
                                    value: binPath,
                                    groupValue: choosePath,
                                    onChanged: (String? value) {
                                      choosePath = value;
                                      setState(() {});
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.w),
                    CardItem(
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                            child: Text(
                              S.of(context).installDes1,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12.w,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.w),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                            child: Text(
                              S.of(context).installDes2,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.w,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8.w,
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10.w),
                            ),
                            child: Text(
                              S.of(context).installDes3,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.w,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.w),
                    CardItem(
                      child: SizedBox(
                        height: 200,
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
                    const SizedBox(
                      height: 32.0,
                    ),
                    NiCardButton(
                      blurRadius: 0,
                      shadowColor: Colors.transparent,
                      borderRadius: 12.w,
                      color: AppColors.accent,
                      onTap: () async {
                        final StringBuffer buffer = StringBuffer();
                        buffer.writeln('su -c "');
                        buffer.writeln(
                          'cp ${RuntimeEnvir.binPath}/adb $choosePath/adb',
                        );
                        buffer.writeln(
                          'cp ${RuntimeEnvir.binPath}/adb.bin $choosePath/adb.bin',
                        );
                        buffer.writeln('chmod 0777 $choosePath/adb');
                        buffer.writeln('chmod 0777 $choosePath/adb.bin"\n');
                        Global().pty!.writeString(buffer.toString());
                      },
                      child: SizedBox(
                        width: 414.w,
                        height: 48.w,
                        child: Center(
                          child: Text(
                            '安装',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 32.0,
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
