import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:adb_tool/drawer.dart';
import 'package:custom_log/custom_log.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:global_repository/global_repository.dart';
import 'package:provider/provider.dart';
import 'config/global.dart';
import 'global/provider/devices_state.dart';
import 'global/provider/process_info.dart';
import 'page/exec_cmd_page.dart';
import 'page/home/pages/home_page.dart';
import 'page/install/adb_install_page.dart';
import 'page/install/adb_insys_page.dart';
import 'page/net_debug/remote_debug_page.dart';
import 'page/search_ip_page.dart';

void main() {
  if (kIsWeb) {
    runApp(
      SizedBox(
        width: 414,
        height: 896,
        child: MediaQuery(
          data: MediaQueryData(size: Size(414, 896)),
          child: MaterialApp(
            shortcuts: <LogicalKeySet, Intent>{
              ...WidgetsApp.defaultShortcuts,
              LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
            },
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'sarasa',
            ),
            home: AdbTool(),
          ),
        ),
      ),
    );
  } else {
    runApp(
      NiToastNew(
        child: MaterialApp(
          shortcuts: <LogicalKeySet, Intent>{
            ...WidgetsApp.defaultShortcuts,
            LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
          },
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'sarasa',
          ),
          home: AdbTool(),
        ),
      ),
    );
  }

  log(
    'error',
    level: 0,
    // le
  );
  log(
    'error',
    level: 1,
    // le
  );
  log(
    'error',
    level: 2,
    // le
  );
  log(
    'error',
    level: 3,
    // le
  );
  Log.w('waring');
  Log.e('error');
  Log.i('info');
  Log.d('debug');
  // if (Platform.isAndroid) {
  //   final MethodChannel methodChannel = MethodChannel('multicast-lock');
  //   methodChannel.invokeMethod<void>('aquire');
  // }
  PlatformUtil.setPackageName('com.nightmare.adbtools');
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProcessState>(
          create: (_) => ProcessState(),
        ),
        ChangeNotifierProvider<DevicesState>(
          create: (_) => DevicesState(),
        ),
      ],
      child: Theme(
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
        child: FutureBuilder<void>(
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
              ScreenUtil.init(
                context,
                width: 414,
                height: 896,
                allowFontScaling: false,
              );
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
        ),
      ),
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
    Global.instance.processState = Provider.of<ProcessState>(context);
    return Material(
      child: Scaffold(
        body: NiScaffold(
          drawer: DrawerPage(
            index: pageIndex,
            onChange: (index) {
              pageIndex = index;
              setState(() {});
              if (kIsWeb || PlatformUtil.isMobilePhone()) {
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
  HomePage(),
  AdbInstallToSystemPage(),
  SearchIpPage(),
  RemoteDebugPage(),
  ExecCmdPage(),
];

// class NetworkInterfaceWidget extends StatefulWidget {
//   @override
//   _NetworkInterfaceState createState() => _NetworkInterfaceState();
// }

// class _NetworkInterfaceState extends State<NetworkInterfaceWidget> {
//   String _networkInterface;
//   @override
//   initState() {
//     super.initState();

//     NetworkInterface.list(includeLoopback: false, type: InternetAddressType.any)
//         .then((List<NetworkInterface> interfaces) {
//       setState(() {
//         _networkInterface = "";
//         interfaces.forEach((interface) {
//           _networkInterface += "### name: ${interface.name}\n";
//           int i = 0;
//           interface.addresses.forEach((address) {
//             _networkInterface += "${i++}) ${address.address}\n";
//           });
//         });
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("NetworkInterface"),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(10.0),
//         child:
//             Text("Only in iOS.. :(\n\nNetworkInterface:\n $_networkInterface"),
//       ),
//     );
//   }
// }
