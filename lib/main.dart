library adb_tool;

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:adb_kit/test_controller.dart';
import 'package:adb_util/adb_util.dart';
import 'package:file_manager/file_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart' hide exec;
import 'package:path_provider/path_provider.dart';
import 'package:plugins/plugins.dart' as plugins;
import 'generated/l10n.dart';
import 'material_entrypoint.dart';
import 'config/config.dart';
import 'package:adb_kit_extension/adb_kit_extension.dart';
import 'generated/intl/messages_en.dart' as messages_en;
import 'generated/intl/messages_zh_CN.dart' as messages_zh_cn;
import 'dart:ui' as ui;

Future<void> main() async {
  // 初始化运行时环境
  plugins.registerADBPlugin();
  runADBClient();
}

Socket? socket;
Future<void> runADBClient() async {
  // hook getx log
  Get.config(
    enableLog: false,
    logWriterCallback: (text, {bool? isError}) {
      Log.d(text, tag: 'GetX');
    },
  );
  // 启动文件管理器服务，以供 ADB KIT 选择本机文件
  Server.start();
  runZonedGuarded<void>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      initPersonal();
      if (!GetPlatform.isIOS) {
        final dir = (await getApplicationSupportDirectory()).path;
        Log.d('ApplicationSupportDirectory: $dir');
        RuntimeEnvir.initEnvirWithPackageName(
          Config.packageName,
          appSupportDirectory: dir,
        );
      }
      await initSetting();
      if (kDebugMode && GetPlatform.isMacOS) {
        // String testCMD = '/Users/nightmare/Desktop/nightmare-core/adb_kit/packages/adb_util/test/test.sh';
        // adb = testCMD;
      }
      if (false) {
      } else {
        // final server = await ServerSocket.bind(InternetAddress.anyIPv4, 4040);
        // server.listen((event) {
        //   Log.i('有客户端连接');
        //   socket = event;
        // });
        // WidgetsBinding.instance.addPersistentFrameCallback((Duration timeStamp) {
        //   // 在这里处理每一帧的回调
        //   sendFrame();
        // });
        // Get.put(TestController());
        runApp(const MaterialAppWrapper());
      }
      mergeI18n();
    },
    (error, stackTrace) {
      Log.e('Uncaught Dart Exception -> $error \n$stackTrace');
    },
    zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
        parent.print(zone, line);
        // Log.d(line);
      },
    ),
  );
  DartPluginRegistrant.ensureInitialized();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    Log.e('${S.current.uncaughtUE} -> ${details.exception}');
  };
  StatusBarUtil.transparent();
}

void mergeI18n() {
  messages_en.messages.messages.addAll(enMessage);
  messages_zh_cn.messages.messages.addAll(zhCNMessage);
  messages_en.messages.messages.addAll(plugins.en_message);
  messages_zh_cn.messages.messages.addAll(plugins.zh_cn_messages);
}

GlobalKey globalKey = GlobalKey();
bool _sendingFrame = false;

Future<void> _capturePng() async {
  try {
    RenderRepaintBoundary boundary = globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(
      pixelRatio: window.devicePixelRatio,
    );
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    TestController testController = Get.find();
    testController.imageBytes = pngBytes;
    testController.size = Size(image.width.toDouble(), image.height.toDouble());
    // Log.i('size -> ${testController.size.width} ${testController.size.height} ');
    testController.update();
    Directory? extenalStorage = await getExternalStorageDirectory();
    // print(pngBytes.toList());
    // Log.i('first 10 -> ${pngBytes.sublist(0, 10)}');
    // Log.i('last 10 -> ${pngBytes.sublist(pngBytes.length - 10)}');
    // File('${extenalStorage?.path}/test.txt').writeAsStringSync(pngBytes.toList().join('\n'));
    if (socket != null) {
      var byteData = ByteData(4);
      byteData.setUint32(0, pngBytes.length, Endian.big);
      socket!.add(byteData.buffer.asUint8List());
      socket!.add(pngBytes);
      socket!.flush();
    }
    // 你可以在这里处理pngBytes，比如保存到文件或展示在UI中
    // print(pngBytes);
  } catch (e) {
    print(e);
  }
}

Future<void> sendFrame() async {
  if (_sendingFrame) {
    return;
  }
  _sendingFrame = true;
  await _capturePng();
  // final RenderView renderView = WidgetsBinding.instance.rootElement!.renderObject! as RenderView;
  // final OffsetLayer layer = renderView.debugLayer! as OffsetLayer;
  // final ui.Image image = await layer.toImage(
  //   Offset.zero & (renderView.size * renderView.flutterView.devicePixelRatio),
  // );
  // image.width;
  // image.height;
  // final Uint8List data = (await image.toByteData(
  //   format: ui.ImageByteFormat.rawRgba,
  // ))!
  //     .buffer
  //     .asUint8List();
  // TestController testController = Get.find();
  // testController.size = Size(image.width.toDouble(), image.height.toDouble());
  // testController.imageBytes = data;
  // testController.update();
  // image.dispose();
  // if (socket != null) {
  //   socket!.add(data);
  //   socket!.flush();
  // }
  _sendingFrame = false;
}

class TestMaterialApp extends StatefulWidget {
  const TestMaterialApp({super.key});

  @override
  State<TestMaterialApp> createState() => _TestMaterialAppState();
}

class _TestMaterialAppState extends State<TestMaterialApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: TestFrame(),
    );
  }
}

class TestFrame extends StatefulWidget {
  const TestFrame({super.key});

  @override
  State<TestFrame> createState() => _TestFrameState();
}

class _TestFrameState extends State<TestFrame> {
  Socket? socket;
  Uint8List data = Uint8List(0);
  int expectedLength = 0;
  List<int> buffer = [];
  Completer<void> renderLock = Completer<void>();

  @override
  void initState() {
    super.initState();
    connect();
  }

  Future<void> connect() async {
    socket = await Socket.connect('192.168.31.109', 4040);
    Log.i('socket -> $socket');
    await for (final event in socket!) {
      buffer.addAll(event);
      while (buffer.length >= 4 && (expectedLength == 0 || buffer.length >= expectedLength)) {
        if (expectedLength == 0 && buffer.length >= 4) {
          expectedLength = ByteData.sublistView(Uint8List.fromList(buffer.sublist(0, 4))).getUint32(0, Endian.big);
          buffer = buffer.sublist(4);
        }
        if (expectedLength > 0 && buffer.length >= expectedLength) {
          data = Uint8List.fromList(buffer.sublist(0, expectedLength));

          // Log.i('first 10 -> ${data.sublist(0, 10)}');
          // Log.i('last 10 -> ${data.sublist(data.length - 10)}');
          // File('test.txt').writeAsStringSync(data.toList().join('\n'));
          buffer = buffer.sublist(expectedLength);
          // Log.i('buffer -> ${buffer.length} expectedLength $expectedLength data :${data.length}');
          expectedLength = 0;
          renderLock = Completer<void>();
          setState(() {});
          await renderLock.future;
          // Log.i('renderLock done');
        }
      }
      Log.i('while done');
    }

    // socket?.listen((event) {
    //   buffer.addAll(event);
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Image(
      image: PixelMemoryImage(
        data,
        1200,
        2670,
        ui.PixelFormat.rgba8888,
      ),
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return const SizedBox();
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        if (frame != null) {}
        if (!renderLock.isCompleted) {
          renderLock.complete();
        }
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox();
      },
    );
  }
}
