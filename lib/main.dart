library adb_tool;

import 'dart:io';
import 'dart:ui';
import 'package:adb_tool/app/modules/log_page.dart';
import 'package:adb_tool/config/settings.dart';
import 'package:app_manager/app_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:nativeshell/nativeshell.dart';
import 'app/routes/app_pages.dart';
import 'config/config.dart';
import 'global/instance/global.dart';
import 'themes/app_colors.dart';
import 'themes/theme.dart';
import 'package:settings/settings.dart';

// 这个值由shell去替换
bool useNativeShell = false;

void main() {
  // 初始化运行时环境
  if (!GetPlatform.isIOS) {
    RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  }
  WidgetsFlutterBinding.ensureInitialized();
  if (useNativeShell) {
    runApp(NativeShellWrapper());
  } else {
    runApp(const AppEntryPoint());
  }
  initSetting();
  Global.instance.initGlobal();
 SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  // ValueListenableBuilder
  // DateTime();
}

Future<void> initSetting() async {
  await initSettingStore(RuntimeEnvir.filesPath);
  Log.e(Settings.serverPath.get);
  if (Settings.serverPath.get.isEmpty) {
    Settings.serverPath.set = Config.adbLocalPath;
  }
  Log.e(Settings.serverPath.get);
}

// App 的顶级widget
class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({
    Key key,
    this.isNativeShell = false,
  }) : super(key: key);
  final bool isNativeShell;

  @override
  _AppEntryPointState createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    _lastSize = WidgetsBinding.instance.window.physicalSize;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Size _lastSize;

  @override
  void didChangeMetrics() {
    _lastSize = WidgetsBinding.instance.window.physicalSize;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Log.w('_lastSize -> $_lastSize');
    if (Platform.isAndroid && _lastSize == null) {
      return Material(
        child: Center(
          child: SpinKitDualRing(
            color: AppColors.accent,
            size: 20.w,
            lineWidth: 2.w,
          ),
        ),
      );
    }
    // desktop初始会是 2,2
    if (_lastSize != null && _lastSize.width > 100) {
      final double screenWidth = _lastSize.width / window.devicePixelRatio;
      final double screenHeight = _lastSize.height / window.devicePixelRatio;
      Global().initTerminalSize(
        Size(screenWidth, screenHeight),
      );
    }

    return OrientationBuilder(
      builder: (_, Orientation orientation) {
        return ToastApp(
          child: GetMaterialApp(
            enableLog: false,
            debugShowCheckedModeBanner: false,
            title: 'ADB工具箱',
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
              if (widget.isNativeShell) {
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

          state ??= OtherWindowState.fromInitData(initData);
          // possibly no init data, this is main window
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
  Future<void> windowCloseRequested() async {
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    return const AppEntryPoint(
      isNativeShell: true,
    );
  }
}

class OtherWindowState extends WindowState {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Responsive(
        builder: (_, __) {
          return LogPage();
        },
      ),
    );
  }

  // This can be anything that fromInitData recognizes
  static dynamic toInitData() => {
        'class': 'OtherWindow',
      };

  static OtherWindowState fromInitData(dynamic initData) {
    if (initData is Map && initData['class'] == 'OtherWindow') {
      return OtherWindowState();
    }
    return null;
  }

  @override
  WindowSizingMode get windowSizingMode =>
      WindowSizingMode.atLeastIntrinsicSize;
}
