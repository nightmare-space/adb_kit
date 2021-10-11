library adb_tool;

import 'dart:io';
import 'package:app_manager/app_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:nativeshell/nativeshell.dart';
import 'package:signale/signale.dart';
import 'package:termare_pty/main.dart';

import 'app/modules/drag_drop.dart';
import 'app/routes/app_pages.dart';
import 'config/config.dart';
import 'global/instance/global.dart';
import 'themes/theme.dart';
import 'utils/assets_utils.dart';

void main() {
  // 初始化运行时环境
  RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  // 初始化终端等
  Global.instance;
  // runApp(NativeShellWrapper());
  runApp(AppEntryPoint());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  installRes();
  // DateTime();
}

/// 安装资源
Future<void> installRes() async {
  if (kIsWeb) {
    return;
  }
  final filePath = RuntimeEnvir.binPath + '/server.jar';
  final Directory dir = Directory(RuntimeEnvir.binPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }
  AssetsUtils.copyAssetToPath('assets/server.jar', filePath);
  final ProcessResult result = await Process.run(
    'chmod',
    <String>['+x', filePath],
  );
  Log.d(
    '更改 server.jar 权限输出 stdout:${result.stdout} stderr；${result.stderr}',
  );
  // print(await exec('scrcpy'));
}

// App 的顶级widget
class AppEntryPoint extends StatelessWidget {
  const AppEntryPoint({
    Key key,
    this.isNativeShell = false,
  }) : super(key: key);

  final bool isNativeShell;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (_, Orientation orientation) {
        return ToastApp(
          child: GetMaterialApp(
            enableLog: false,
            debugShowCheckedModeBanner: false,
            title: 'ADB Manager',
            navigatorKey: Global.instance.navigatorKey,
            themeMode: ThemeMode.light,
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            defaultTransition: Transition.fadeIn,
            initialRoute: AdbPages.INITIAL,
            getPages: AdbPages.routes + AppPages.routes,
            builder: (BuildContext context, Widget navigator) {
              if (orientation == Orientation.landscape) {
                context.init(896);
              } else {
                context.init(414);
              }
              // config中的Dimens获取不到ScreenUtil，因为ScreenUtil中用到的MediaQuery只有在
              // WidgetApp或者很长MaterialApp中才能获取到，所以在build方法中处理主题
              final bool isDark =
                  Theme.of(context).brightness == Brightness.dark;
              final ThemeData theme =
                  isDark ? DefaultThemeData.dark() : DefaultThemeData.light();

              /// NativeShell
              if (isNativeShell) {
                return WindowLayoutProbe(
                  child: Container(
                    width: 800,
                    height: 600,
                    child: Responsive(
                      builder: (_, __) {
                        return Theme(
                          data: theme,
                          child: navigator,
                        );
                      },
                    ),
                  ),
                );
              }

              ///
              ///
              ///
              /// Default Mode
              ///
              return Responsive(
                builder: (_, __) {
                  return Theme(
                    data: theme,
                    child: navigator,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}

class NativeShellWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: WindowWidget(
        onCreateState: (initData) {
          WindowState state;
          state ??= MainWindowState();
          return state;
        },
      ),
    );
  }
}

class MainWindowState extends WindowState {
  @override
  WindowSizingMode get windowSizingMode =>
      WindowSizingMode.atLeastIntrinsicSize;

  @override
  Widget build(BuildContext context) {
    return AppEntryPoint();
  }
}
