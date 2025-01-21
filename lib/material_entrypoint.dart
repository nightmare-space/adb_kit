// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:ui';
import 'package:adb_kit/test_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:screenshot/screenshot.dart';
import 'package:settings/settings.dart';
import 'app/controller/controller.dart';
import 'app/routes/app_pages.dart';
import 'config/config.dart';
import 'config/settings.dart';
import 'generated/l10n.dart';
import 'global/instance/global.dart';
import 'main.dart';
import 'themes/theme.dart';
import 'dart:ui' as ui;

Future<void> initSetting() async {
  await initSettingStore(RuntimeEnvir.configPath);
  if (Settings.serverPath.setting.get() == null) {
    Settings.serverPath.setting.set(Config.adbLocalPath);
  }
}

class MaterialAppWrapper extends StatefulWidget {
  const MaterialAppWrapper({
    super.key,
    this.isNativeShell = false,
  });
  final bool isNativeShell;

  @override
  State createState() => _MaterialAppWrapperState();
}

class _MaterialAppWrapperState extends State<MaterialAppWrapper> with WidgetsBindingObserver {
  ConfigController config = Get.put(ConfigController());

  ScreenshotController screenshotController = ScreenshotController();
  @override
  Widget build(BuildContext context) {
    return ToastApp(
      child: app(),
    );
  }

  BackdropFilter app() {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 24.0,
        sigmaY: 24.0,
      ),
      child: rootWidgetBuilder(),
    );
  }

  GetBuilder<ConfigController> rootWidgetBuilder() {
    return GetBuilder<ConfigController>(
      builder: (config) {
        config.initConfig();
        return Screenshot(
          controller: screenshotController,
          child: KeyboardListener(
            autofocus: true,
            focusNode: FocusNode(),
            onKeyEvent: ((value) {
              // Log.w(value);
              // if (value is RawKeyDownEvent) {
              //   screenshotController.captureAndSave('./screenshot');
              // }
            }),
            child: GetMaterialApp(
              showPerformanceOverlay: config.showPerformanceOverlay,
              showSemanticsDebugger: config.showSemanticsDebugger,
              debugShowMaterialGrid: config.debugShowMaterialGrid,
              checkerboardRasterCacheImages: config.checkerboardRasterCacheImages,
              debugShowCheckedModeBanner: false,
              title: 'ADB工具箱',
              navigatorKey: Global().navigatorKey,
              themeMode: ThemeMode.light,
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              locale: config.locale,
              supportedLocales: S.delegate.supportedLocales,
              theme: ThemeData(primarySwatch: Colors.blue, visualDensity: VisualDensity.adaptivePlatformDensity),
              defaultTransition: Transition.fadeIn,
              initialRoute: ADBPages.splash,
              getPages: ADBPages.routes,
              useInheritedMediaQuery: true,
              builder: (BuildContext context, Widget? navigator) {
                return ResponsiveBreakpoints.builder(
                  child: Builder(
                    builder: (context) {
                      if (ResponsiveBreakpoints.of(context).isDesktop || ResponsiveBreakpoints.of(context).isTablet) {
                        ScreenAdapter.init(896);
                      } else {
                        ScreenAdapter.init(414);
                      }
                      late ThemeData theme;
                      if (config.theme == null) {
                        final bool isDark = window.platformBrightness == Brightness.dark;
                        theme = isDark ? dark() : light();
                      } else {
                        theme = config.theme!;
                      }
                      return Stack(
                        children: [
                          RepaintBoundary(
                            key: globalKey,
                            child: ScreenQuery(
                              uiWidth: 414,
                              screenWidth: MediaQuery.of(context).size.width,
                              child: Theme(
                                data: theme,
                                child: navigator ?? const SizedBox(),
                              ),
                            ),
                          ),
                          // Align(
                          //   alignment: Alignment.topRight,
                          //   child: SizedBox(
                          //     width: 100,
                          //     child: Preview(),
                          //   ),
                          // ),
                        ],
                      );
                    },
                  ),
                  landscapePlatforms: ResponsiveTargetPlatform.values,
                  breakpoints: const [
                    Breakpoint(start: 0, end: 500, name: MOBILE),
                    Breakpoint(start: 500, end: 800, name: TABLET),
                    Breakpoint(start: 800, end: double.infinity, name: DESKTOP),
                  ],
                  breakpointsLandscape: [
                    const Breakpoint(start: 0, end: 450, name: MOBILE),
                    const Breakpoint(start: 451, end: 800, name: TABLET),
                    const Breakpoint(start: 801, end: double.infinity, name: DESKTOP),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class Preview extends StatefulWidget {
  const Preview({super.key});

  @override
  State<Preview> createState() => _PreviewState();
}

class _PreviewState extends State<Preview> {
  TestController testController = Get.find();
  bool success = true;
  @override
  void initState() {
    super.initState();
    testController.addListener(() {
      if (success) {
        success = false;
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    MemoryImage;
    FileImage;
    return Image(
      image: PixelMemoryImage(
        testController.imageBytes,
        testController.size.width.toInt(),
        testController.size.height.toInt(),
        ui.PixelFormat.rgba8888,
      ),
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          success = true;
          return child;
        }
        if (frame != null) {
          success = true;
        }
        return child;
      },
    );
    return Image.memory(
      testController.imageBytes,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          success = true;
          return child;
        }
        if (frame != null) {
          success = true;
        }
        return child;
      },
    );
  }
}

class PixelMemoryImage extends ImageProvider<PixelMemoryImage> {
  PixelMemoryImage(this.bytes, this.width, this.height, this.format);

  final Uint8List bytes;
  final int width;
  final int height;
  final ui.PixelFormat format;

  @override
  Future<PixelMemoryImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PixelMemoryImage>(this);
  }

  @override
  ImageStreamCompleter loadBuffer(PixelMemoryImage key, _) {
    Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(bytes, width, height, format, completer.complete);
    return OneFrameImageStreamCompleter(completer.future.then((ui.Image image) => ImageInfo(image: image)));
  }

  @override
  ImageStreamCompleter loadImage(PixelMemoryImage key, _) {
    Completer<ui.Image> completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(bytes, width, height, format, completer.complete);
    return OneFrameImageStreamCompleter(completer.future.then((ui.Image image) => ImageInfo(image: image)));
  }
}
