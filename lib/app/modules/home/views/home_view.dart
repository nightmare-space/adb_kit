import 'dart:io';
import 'dart:typed_data';

import 'package:adb_tool/app/modules/history/history_page.dart';
import 'package:adb_tool/app/modules/install/adb_insys_page.dart';
import 'package:adb_tool/app/modules/net_debug/remote_debug_page.dart';
import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/drawer.dart';
import 'package:adb_tool/app/modules/exec_cmd_page.dart';
import 'package:adb_tool/app/modules/search_ip_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return AdbTool();
  }
}

class AdbTool extends StatefulWidget {
  AdbTool({
    Key key,
    this.packageName,
  }) : super(key: key) {
    if (packageName != null) {
      // 改包可能是被其他项目集成的
      Config.packageName = packageName;
      Config.flutterPackage = 'packages/adb_tool/';
    }
    if (Get.arguments != null) {
      Config.packageName = Get.arguments.toString();
      Config.flutterPackage = 'packages/adb_tool/';
    }
  }

  final String packageName;
  @override
  _AdbToolState createState() => _AdbToolState();
}

class _AdbToolState extends State<AdbTool> {
  @override
  void initState() {
    super.initState();
    installAdbToEnvir();
  }

  List<String> androidFiles = [
    '${Config.flutterPackage}assets/android/adb',
    '${Config.flutterPackage}assets/android/adb.bin',
  ];
  Future<void> installAdbToEnvir() async {
    if (kIsWeb) {
      return true;
    }
    await Global.instance.initGlobal();
    if (Platform.isAndroid) {
      for (final String fileKey in androidFiles) {
        final ByteData byteData = await rootBundle.load(
          fileKey,
        );
        final Uint8List picBytes = byteData.buffer.asUint8List();
        final String filePath = PlatformUtil.getBinaryPath() +
            '/' +
            PlatformUtil.getFileName(fileKey);
        final File file = File(filePath);
        if (!await file.exists()) {
          await file.writeAsBytes(picBytes);
          await Process.run('chmod', <String>['+x', filePath]);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          textTheme: TextTheme(
            headline6: TextStyle(
              height: 1.0,
              fontSize: 20.0,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      child: OrientationBuilder(
        builder: (_, Orientation orientation) {
          if (kIsWeb || PlatformUtil.isDesktop()) {
            ScreenUtil.init(
              context,
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              allowFontScaling: false,
            );
          } else {
            if (orientation == Orientation.landscape) {
              ScreenUtil.init(
                context,
                width: 896,
                height: 414,
                allowFontScaling: false,
              );
            } else {
              ScreenUtil.init(
                context,
                width: 414,
                height: 896,
                allowFontScaling: false,
              );
            }
          }
          if (kIsWeb) {
            return Center(
              child: SizedBox(
                width: 414,
                height: 896,
                child: MediaQuery(
                  data: const MediaQueryData(size: Size(414, 896)),
                  child: _AdbTool(),
                ),
              ),
            );
          }
          return _AdbTool();
        },
      ),
    );
  }
}

class _AdbTool extends StatefulWidget {
  @override
  __AdbToolState createState() => __AdbToolState();
}

class __AdbToolState extends State<_AdbTool> {
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: NiScaffold(
          backgroundColor: Colors.transparent,
          drawer: DrawerPage(
            index: pageIndex,
            onChange: (index) {
              pageIndex = index;
              setState(() {});
              if (MediaQuery.of(context).orientation == Orientation.portrait) {
                // 这个if可能会有点问题
                Navigator.pop(context);
              }
            },
          ),
          body: listWidget[pageIndex],
        ),
      ),
    );
  }
}

List<Widget> listWidget = [
  OverviewPage(),
  AdbInstallToSystemPage(),
  SearchIpPage(),
  RemoteDebugPage(),
  ExecCmdPage(),
  HistoryPage(),
];
