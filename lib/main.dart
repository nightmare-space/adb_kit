import 'package:adb_tool/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'config/config.dart';
import 'config/global.dart';
import 'global/provider/devices_state.dart';
import 'global/provider/process_info.dart';
import 'page/adb_install_page.dart';
import 'page/adb_insys_page.dart';
import 'page/exec_cmd_page.dart';
import 'page/home_page.dart';
import 'page/search_ip_page.dart';
import 'utils/platform_util.dart';

void main() {
  runApp(
    MaterialApp(
      home: AdbTool(),
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
  Config.init();
}

class AdbTool extends StatefulWidget {
  @override
  _AdbToolState createState() => _AdbToolState();
}

class _AdbToolState extends State<AdbTool> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        ChangeNotifierProvider<ProcessState>(
          create: (_) => ProcessState(),
        ),
        ChangeNotifierProvider<DevicesState>(
          create: (_) => DevicesState(),
        ),
      ],
      child: FutureBuilder<bool>(
        future: PlatformUtil.cmdIsExist('adb'),
        builder: (context, snapshot) {
          ScreenUtil.init(
            context,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            allowFontScaling: false,
          );
          return _AdbTool();
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              print('还没有开始网络请求');
              return const Text('');
            case ConnectionState.active:
              print('active');
              return const Text('ConnectionState.active');
            case ConnectionState.waiting:
              print('waiting');
              return const Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              print('done');
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              if (!snapshot.data) {
                return AdbInstallPage();
              }
              return _AdbTool();
            default:
              return null;
          }
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
  int currentIndex = 0;
  // 页面的键
  String curKey = 'main';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Global.instance.processState ??= Provider.of<ProcessState>(context);
    return Material(
      child: Scaffold(
        backgroundColor: Colors.white,
        // floatingActionButton: FloatingActionButton(onPressed: () {
        //   NiProcess.exit();
        // }),
        appBar: AppBar(
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.0,
          title: Text(
            'ADB 工具',
            style: TextStyle(
              height: 1.0,
              color: Theme.of(context).textTheme.bodyText2.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: Builder(
            builder: (_) {
              return IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
                onPressed: () {
                  Scaffold.of(_).openDrawer();
                },
              );
            },
          ),
        ),
        drawer: DrawerPage(
          onChange: (key) {
            curKey = key;
            setState(() {});
            print(key);
            Navigator.pop(context);
          },
        ),
        body: _getPage(curKey),
      ),
    );
  }
}

Widget _getPage(String key) {
  switch (key) {
    case 'main':
      return HomePage();
      break;
    case 'exec-cmd':
      return ExecCmdPage();
      break;
    case 'install-adb':
      return AdbInstallToSystemPage();
      break;

    case 'search-ip':
      return SearchIpPage();
      break;
    default:
      return ExecCmdPage();
  }
}
