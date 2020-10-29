import 'package:adb_tool/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'global/provider/devices_state.dart';
import 'global/provider/process_state.dart';
import 'page/exec_cmd_page.dart';
import 'page/home_page.dart';
import 'utils/custom_process.dart';

void main() {
  runApp(AdbTool());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
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
      child: MaterialApp(
        home: _AdbTool(),
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
    init();
  }

  Future<void> init() async {
    // final String result = await NiProcess.exec('ip neigh');
    // print(result);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    default:
      return ExecCmdPage();
  }
}
