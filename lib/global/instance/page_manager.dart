import 'package:adb_tool/core/interface/adb_page.dart';
import 'package:adb_tool/core/interface/pluggable.dart';

class PageManager {
  static PageManager _instance;

  List<ADBPage> get pages => _pages;

  final List<ADBPage> _pages = [];

  Pluggable _activatedPluggable;
  String get activatedPluggableName => _activatedPluggable?.name;

  static PageManager get instance {
    _instance ??= PageManager._();
    return _instance;
  }

  PageManager._();

  /// Register a single [plugin]
  void register(ADBPage page) {
    _pages.add(page);
  }
}
