import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:adb_tool/app/modules/connect/connect_page.dart';
import 'package:adb_tool/app/modules/drawer/desktop_phone_drawer.dart';
import 'package:adb_tool/app/modules/drawer/tablet_drawer.dart';
import 'package:adb_tool/app/modules/exec_cmd_page.dart';
import 'package:adb_tool/app/modules/history/history_page.dart';
import 'package:adb_tool/app/modules/install/adb_insys_page.dart';
import 'package:adb_tool/app/modules/net_debug/remote_debug_page.dart';
import 'package:adb_tool/app/modules/overview/pages/overview_page.dart';
import 'package:adb_tool/app/modules/search_ip_page.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/global/instance/global.dart';
import 'package:adb_tool/themes/app_colors.dart';
import 'package:adb_tool/themes/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/utils.dart';
import 'package:global_repository/global_repository.dart';
import 'package:path/path.dart' as p;

class AdbTool extends StatefulWidget {
  AdbTool({
    Key key,
    this.packageName,
  }) : super(key: key) {
    if (RuntimeEnvir.packageName != Config.packageName &&
        !GetPlatform.isDesktop) {
      // 如果这个项目是独立运行的，那么RuntimeEnvir.packageName会在main函数中被设置成Config.packageName
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
    'adb',
    'libbrotlidec.so',
    'libbrotlienc.so',
    'libc++_shared.so',
    'liblz4.so.1',
    'libprotobuf.so',
    'libusb-1.0.so',
    'libz.so.1',
    'libzstd.so.1',
    'libbrotlicommon.so',
  ];

  Future<void> installAdbToEnvir() async {
    if (kIsWeb) {
      return true;
    }
    await Global.instance.initGlobal();
    if (Platform.isAndroid) {
      await Directory(RuntimeEnvir.binPath).create(recursive: true);
      for (final String fileKey in androidFiles) {
        final ByteData byteData = await rootBundle.load(
          '${Config.flutterPackage}assets/android/' + fileKey,
        );
        final Uint8List picBytes = byteData.buffer.asUint8List();
        final String filePath = RuntimeEnvir.binPath + '/' + fileKey;
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
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: AppColors.fontTitle,
          ),
          textTheme: TextTheme(
            headline6: TextStyle(
              height: 1.0,
              fontSize: 20.0,
              color: AppColors.fontTitle,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        colorScheme: const ColorScheme.light().copyWith(
          secondary: AppColors.accent,
        ),
      ),
      child: OrientationBuilder(
        builder: (_, Orientation orientation) {
          final Size size = window.physicalSize / window.devicePixelRatio;
          Log.w(MediaQuery.of(context).size.width);
          Log.w(window.physicalSize / window.devicePixelRatio);
          Log.w(window.devicePixelRatio);
          if (orientation == Orientation.landscape) {
            ScreenAdapter.init(896);
          } else {
            ScreenAdapter.init(414);
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
          final bool isDark = Theme.of(context).brightness == Brightness.dark;
          final ThemeData theme =
              isDark ? DefaultThemeData.dark() : DefaultThemeData.light();
          return Theme(
            data: theme,
            child: _AdbTool(),
          );
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
    return Responsive(
      builder: (_, ScreenType screenType) {
        Log.e(MediaQuery.of(context).size.width);
        Log.e(screenType);
        switch (screenType) {
          case ScreenType.desktop:
            return Scaffold(
              body: Row(
                children: [
                  DesktopPhoneDrawer(
                    width: Dimens.setWidth(200),
                    groupValue: pageIndex,
                    onChanged: (index) {
                      pageIndex = index;
                      setState(() {});
                    },
                  ),
                  Expanded(child: getWidget(pageIndex)),
                ],
              ),
            );
            break;
          case ScreenType.tablet:
            return Scaffold(
              body: Row(
                children: [
                  TabletDrawer(
                    groupValue: pageIndex,
                    onChanged: (index) {
                      pageIndex = index;
                      setState(() {});
                    },
                  ),
                  Expanded(child: getWidget(pageIndex)),
                ],
              ),
            );
            break;
          case ScreenType.phone:
            return Scaffold(
              drawer: DesktopPhoneDrawer(
                width: MediaQuery.of(context).size.width * 2 / 3,
                groupValue: pageIndex,
                onChanged: (index) {
                  pageIndex = index;
                  setState(() {});
                  Navigator.pop(context);
                },
              ),
              body: Row(
                children: [
                  Expanded(child: getWidget(pageIndex)),
                ],
              ),
            );
            break;
          default:
            return const Text('ERROR');
        }
      },
    );
  }
}

// 不单独写这样一个函数而是写一个列表的话，会导致在pc端改变窗口大小，这部分的widget得不到刷新
Widget getWidget(int index) {
  return [
    OverviewPage(),
    ConnectPage(),
    AdbInstallToSystemPage(),
    SearchIpPage(),
    RemoteDebugPage(),
    ExecCmdPage(),
    HistoryPage(),
  ][index];
}
