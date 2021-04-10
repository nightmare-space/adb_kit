import 'dart:io';
import 'dart:typed_data';

import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/drawer.dart';
import 'package:adb_tool/page/exec_cmd_page.dart';
import 'package:adb_tool/page/install/adb_insys_page.dart';
import 'package:adb_tool/page/net_debug/remote_debug_page.dart';
import 'package:adb_tool/page/overview/pages/overview_page.dart';
import 'package:adb_tool/page/search_ip_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return AdbTool();
  }
}

List<String> androidFiles = [
  'assets/android/adb',
  'assets/android/adb.bin',
];

class AdbTool extends StatefulWidget {
  @override
  _AdbToolState createState() => _AdbToolState();
}

class _AdbToolState extends State<AdbTool> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> adbExist() async {
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
    // test();
    return Theme(
      data: ThemeData(
        appBarTheme: const AppBarTheme(
          color: Colors.transparent,
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
      child: OrientationBuilder(builder: (_, Orientation orientation) {
        return FutureBuilder<void>(
          future: adbExist(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
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
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.active:
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
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
              default:
                return null;
            }
          },
        );
      }),
    );
  }
}

class _AdbTool extends StatefulWidget {
  @override
  __AdbToolState createState() => __AdbToolState();
}

class __AdbToolState extends State<_AdbTool> {
  int currentIndex = 0;
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   backgroundColor: Colors.transparent,
    // );
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
];
