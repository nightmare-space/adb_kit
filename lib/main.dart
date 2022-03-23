library adb_tool;

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:adb_tool/app/controller/config_controller.dart';
import 'package:adb_tool/app/modules/log_page.dart';
import 'package:adb_tool/config/settings.dart';
import 'package:app_manager/app_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:nativeshell/nativeshell.dart' as nativeshell;
import 'package:settings/settings.dart';
import 'app/controller/devices_controller.dart';
import 'app/routes/app_pages.dart';
import 'config/config.dart';
import 'generated/l10n.dart';
import 'global/instance/global.dart';
import 'themes/app_colors.dart';
import 'themes/theme.dart';

// 这个值由shell去替换
bool useNativeShell = false;

Future<void> main() async {
  // 初始化运行时环境
  if (!GetPlatform.isIOS) {
    RuntimeEnvir.initEnvirWithPackageName(Config.packageName);
  }
  Log.d(StackTrace.current);
  Get.config(enableLog: false);
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      if (GetPlatform.isDesktop) {
        await Window.initialize();
      }
      await initSetting();
      Get.put(ConfigController());
      Global.instance.initGlobal();
      if (useNativeShell) {
        runApp(const NativeShellWrapper());
      } else {
        runApp(const AppEntryPoint());
      }
    },
    (error, stackTrace) {
      Log.e('未捕捉到的异常 : $error');
    },
  );
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Log.e('页面构建异常 : ${details.exception}');
  };
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}

Future<void> initSetting() async {
  await initSettingStore(RuntimeEnvir.configPath);
  if (Settings.serverPath.get == null) {
    Settings.serverPath.set = Config.adbLocalPath;
  }
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
  ConfigController config = Get.put(ConfigController());

  DevicesController controller = Get.find();
  @override
  void initState() {
    super.initState();
    _lastSize = WidgetsBinding.instance.window.physicalSize;

    controller.init();
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
    final ThemeData theme = config.theme;
    return ToastApp(
      child: Stack(
        children: [
          GetBuilder<ConfigController>(builder: (_) {
            if (config.backgroundStyle == BackgroundStyle.normal) {
              return Container(
                color: theme.colorScheme.background,
              );
            } else {
              return SizedBox(
                height: double.infinity,
                child: Image.asset(
                  'assets/background1.jpg',
                  fit: BoxFit.cover,
                ),
              );
            }
          }),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 10.0,
              sigmaY: 10.0,
            ),
            child: GetBuilder<ConfigController>(
              builder: (context) {
                return GetMaterialApp(
                  showPerformanceOverlay: config.showPerformanceOverlay,
                  showSemanticsDebugger: config.showSemanticsDebugger,
                  debugShowMaterialGrid: config.debugShowMaterialGrid,
                  checkerboardRasterCacheImages:
                      config.checkerboardRasterCacheImages,
                  enableLog: false,
                  debugShowCheckedModeBanner: false,
                  title: 'ADB工具箱',
                  navigatorKey: Global.instance.navigatorKey,
                  themeMode: ThemeMode.light,
                  localizationsDelegates: const [
                    S.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  locale: config.locale,
                  supportedLocales: S.delegate.supportedLocales,
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                  ),
                  defaultTransition: Transition.fadeIn,
                  initialRoute: AdbPages.initial,
                  getPages: AdbPages.routes + AppPages.routes,
                  builder: (BuildContext context, Widget navigator) {
                    Size size = MediaQuery.of(context).size;
                    if (size.width > size.height) {
                      context.init(896);
                    } else {
                      context.init(414);
                    }
                    // config中的Dimens获取不到ScreenUtil，因为ScreenUtil中用到的MediaQuery只有在
                    // WidgetApp或者很长MaterialApp中才能获取到，所以在build方法中处理主题
                    /// NativeShell
                    if (widget.isNativeShell) {
                      return nativeshell.WindowLayoutProbe(
                        child: SizedBox(
                          width: 800,
                          height: 600,
                          child: Theme(
                            data: theme,
                            child: navigator,
                          ),
                        ),
                      );
                    }

                    ///
                    ///
                    ///
                    /// Default Mode
                    ///

                    return Responsive(builder: (context, _) {
                      return Theme(
                        data: theme,
                        child: navigator,
                      );
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class NativeShellWrapper extends StatelessWidget {
  const NativeShellWrapper({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: nativeshell.WindowWidget(
        onCreateState: (initData) {
          nativeshell.WindowState state;

          state ??= OtherWindowState.fromInitData(initData);
          // possibly no init data, this is main window
          state ??= MainWindowState();
          return state;
        },
      ),
    );
  }
}

class MainWindowState extends nativeshell.WindowState {
  @override
  nativeshell.WindowSizingMode get windowSizingMode =>
      nativeshell.WindowSizingMode.atLeastIntrinsicSize;

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

class OtherWindowState extends nativeshell.WindowState {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Responsive(
        builder: (_, __) {
          return const LogPage();
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
  nativeshell.WindowSizingMode get windowSizingMode =>
      nativeshell.WindowSizingMode.atLeastIntrinsicSize;
}
