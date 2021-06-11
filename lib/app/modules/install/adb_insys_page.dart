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
    return Scaffold(
      appBar: AppBar(
        brightness: Brightness.light,
        title: const Text('安装ADB到系统'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      body: Stack(
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
                    children: const <Widget>[
                      ItemHeader(
                        color: CandyColors.candyCyan,
                      ),
                      Text(
                        '安装到系统(需要root)',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      '请选择安装路径',
                      style: TextStyle(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
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
                  Text(
                    'tips:建议选择 /system/xbin ,因为安卓自带程序大部分都在 system/bin ,装在前者更方便管理个人安装的一些可执行程序。',
                    style: TextStyle(
                      color: const Color(0xff707076),
                      fontSize: Dimens.font_sp12,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
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
                  const SizedBox(
                    height: 200,
                    child: TerminalPage(),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              NiCardButton(
                blurRadius: 0,
                shadowColor: Colors.transparent,
                borderRadius: 12.0,
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
                  width: MediaQuery.of(context).size.width,
                  height: Dimens.gap_dp48,
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
        ],
      ),
    );
  }
}
