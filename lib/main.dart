import 'package:adb_tool/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'home_page.dart';
import 'utils/custom_process.dart';

void main() {
  runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentIndex = 0;
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    final String result = await NiProcess.exec('ip neigh');
    print(result);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
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
            leading: Builder(builder: (_) {
              return IconButton(
                icon: Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
                onPressed: () {
                  Scaffold.of(_).openDrawer();
                },
              );
            })
            // actions: <Widget>[
            ),
        drawer: DrawerPage(),
        body: HomePage(),
        // bottomNavigationBar: BottomNavigationBar(
        //   items: bottomNavItems,
        //   currentIndex: currentIndex,
        //   type: BottomNavigationBarType.shifting,
        //   onTap: (index) {
        //     currentIndex = index;
        //     setState(() {});
        //   },
        // ),
      ),
    );
  }
}

final List<BottomNavigationBarItem> bottomNavItems = [
  BottomNavigationBarItem(
    backgroundColor: Colors.blue,
    icon: Icon(Icons.home),
    title: Text("首页"),
  ),
  BottomNavigationBarItem(
    backgroundColor: Colors.green,
    icon: Icon(Icons.message),
    title: Text("消息"),
  ),
  BottomNavigationBarItem(
    backgroundColor: Colors.amber,
    icon: Icon(Icons.shopping_cart),
    title: Text("购物车"),
  ),
  BottomNavigationBarItem(
    backgroundColor: Colors.red,
    icon: Icon(Icons.person),
    title: Text("个人中心"),
  ),
];
