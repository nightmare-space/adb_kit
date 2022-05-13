import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:settings/settings.dart';
import 'package:app_manager/app_manager.dart' as am;
import 'app/controller/controller.dart';
import 'app/modules/log_page.dart';
import 'app/routes/app_pages.dart';
import 'config/config.dart';
import 'config/settings.dart';
import 'generated/l10n.dart';
import 'global/instance/global.dart';

Future<void> initSetting() async {
  await initSettingStore(RuntimeEnvir.configPath);
  if (Settings.serverPath.get == null) {
    Settings.serverPath.set = Config.adbLocalPath;
  }
}

class MaterialAppWrapper extends StatefulWidget {
  const MaterialAppWrapper({
    Key key,
    this.isNativeShell = false,
  }) : super(key: key);
  final bool isNativeShell;

  @override
  _MaterialAppWrapperState createState() => _MaterialAppWrapperState();
}

class _MaterialAppWrapperState extends State<MaterialAppWrapper>
    with WidgetsBindingObserver {
  ConfigController config = Get.put(ConfigController());

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
    return ToastApp(
      child: Stack(
        children: [
          GetBuilder<ConfigController>(builder: (config) {
            if (config.backgroundStyle == BackgroundStyle.normal) {
              return Container(
                color: config.theme.colorScheme.background,
              );
            }
            if (config.backgroundStyle == BackgroundStyle.image) {
              return SizedBox(
                height: double.infinity,
                child: Image.asset(
                  'assets/b.png',
                  fit: BoxFit.cover,
                ),
              );
            } else {
              return const SizedBox();
            }
          }),
          BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 24.0,
              sigmaY: 24.0,
            ),
            child: GetBuilder<ConfigController>(
              builder: (config) {
                return GetMaterialApp(
                  showPerformanceOverlay: config.showPerformanceOverlay,
                  showSemanticsDebugger: config.showSemanticsDebugger,
                  debugShowMaterialGrid: config.debugShowMaterialGrid,
                  checkerboardRasterCacheImages:
                      config.checkerboardRasterCacheImages,
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
                  getPages: AdbPages.routes + am.AppPages.routes,
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
                    if (widget.isNativeShell) {}

                    ///
                    ///
                    ///
                    /// Default Mode
                    ///
                    return ResponsiveWrapper.builder(
                      Builder(builder: (context) {
                        if (ResponsiveWrapper.of(context).isDesktop) {
                          ScreenAdapter.init(896);
                        } else {
                          ScreenAdapter.init(414);
                        }
                        return Theme(
                          data: config.theme,
                          child: navigator,
                        );
                      }),
                      // maxWidth: 1200,
                      minWidth: 10,
                      defaultScale: false,
                      defaultName: PHONE,
                      breakpoints: const [
                        // ResponsiveBreakpoint.resize(400, name: PHONE),
                        ResponsiveBreakpoint.resize(600, name: TABLET),
                        ResponsiveBreakpoint.resize(1000, name: DESKTOP),
                      ],
                    );
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
