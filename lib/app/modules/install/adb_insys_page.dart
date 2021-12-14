import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/global/pages/terminal.dart';
import 'package:adb_tool/global/widget/item_header.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';

// 安装 adb 工具到系统
class AdbInstallToSystemPage extends StatefulWidget {
  @override
  _AdbInstallToSystemPageState createState() => _AdbInstallToSystemPageState();
}

class _AdbInstallToSystemPageState extends State<AdbInstallToSystemPage> {
  String binPath = '/system/bin';
  String xbinPath = '/system/xbin';
  String choosePath;

  @override
  void initState() {
    super.initState();
    choosePath = xbinPath;
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (Responsive.of(context).screenType == ScreenType.phone) {
      appBar = AppBar(
        title: const Text('安装ADB到系统'),
        systemOverlayStyle: OverlayStyle.dark,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      );
    }
    return Scaffold(
      appBar: appBar,
      body: SafeArea(
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
                    Row(
                      children: <Widget>[
                        const ItemHeader(
                          color: CandyColors.candyCyan,
                        ),
                        Text(
                          '选择安装路径',
                          style: TextStyle(
                            fontSize: 16.w,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12.w),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.1),
                          width: 1.w,
                        ),
                      ),
                      margin: EdgeInsets.symmetric(vertical: 8.w),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  xbinPath,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Radio(
                                  value: xbinPath,
                                  groupValue: choosePath,
                                  onChanged: (String value) {
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
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Radio<String>(
                                  value: binPath,
                                  groupValue: choosePath,
                                  onChanged: (String value) {
                                    choosePath = value;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                      child: Text(
                        '建议选择 /system/xbin ,因为安卓自带程序大部分都在 system/bin ,装在前者更方便管理个人安装的一些可执行程序。',
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
                        '该功能暂未适配动态分区',
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
                        '该功能需要ROOT权限',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.w,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: Dimens.gap_dp16,
                    ),
                    Row(
                      children: [
                        const ItemHeader(color: CandyColors.candyPink),
                        Text(
                          '终端',
                          style: TextStyle(
                            fontSize: Dimens.font_sp16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: Dimens.gap_dp16,
                    ),
                    const CardItem(
                      child: SizedBox(
                        height: 200,
                        child: TerminalPage(),
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
                        Global.instance.pseudoTerminal.write(buffer.toString());
                      },
                      child: SizedBox(
                        width: 414.w,
                        height: 48.w,
                        child: const Center(
                          child: Text(
                            '安装',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
