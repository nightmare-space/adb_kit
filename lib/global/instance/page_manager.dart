import 'package:adb_kit/core/interface/adb_page.dart';
import 'package:adb_kit/core/interface/pluggable.dart';
import 'package:adb_kit/global/drawer/about.dart';
import 'package:adb_kit/global/drawer/history.dart';
import 'package:adb_kit/global/drawer/home.dart';
import 'package:adb_kit/global/drawer/log.dart';
import 'package:adb_kit/global/drawer/net_debug.dart';
import 'package:adb_kit/global/drawer/setting.dart';
import 'package:adb_kit/global/drawer/terminal.dart';

class PageManager {
  static PageManager? _instance;

  List<ADBPage> get pages => _pages;

  final List<ADBPage> _pages = [
    Home(),
    History(),
    NetDebug(),
    // InstallToSystem(),
    TerminalDrawer(),
    LogDrawer(),
    Setting(),
    About(),
  ];

  Pluggable? _activatedPluggable;
  String? get activatedPluggableName => _activatedPluggable?.name;

  static PageManager? get instance {
    _instance ??= PageManager._();
    return _instance;
  }

  PageManager._();

  /// Register a single [plugin]
  void register(ADBPage page) {
    _pages.add(page);
  }

  void clear() {
    _pages.clear();
  }
}
