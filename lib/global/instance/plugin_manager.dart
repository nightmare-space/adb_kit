import 'package:adb_kit/core/interface/pluggable.dart';

/// 插件管理器
class PluginManager {
  static PluginManager? _instance;

  Map<String, Pluggable> get pluginsMap => _pluginsMap;

  final Map<String, Pluggable> _pluginsMap = {};

  Pluggable? _activatedPluggable;
  String? get activatedPluggableName => _activatedPluggable?.name;

  static PluginManager get instance {
    _instance ??= PluginManager._();
    return _instance!;
  }

  PluginManager._();

  /// Register a single [plugin]
  void registerADBPlugin(Pluggable plugin) {
    if (plugin.name.isEmpty) {
      return;
    }
    _pluginsMap[plugin.name] = plugin;
  }

  void registerDrawerPage(Pluggable plugin) {
    // TODO
    // if (plugin.name.isEmpty) {
    //   return;
    // }
    // _pluginsMap[plugin.name] = plugin;
  }

  /// Register multiple [plugins]
  void registerAll(List<Pluggable> plugins) {
    for (final plugin in plugins) {
      registerADBPlugin(plugin);
    }
  }

  void activatePluggable(Pluggable pluggable) {
    _activatedPluggable = pluggable;
  }

  void deactivatePluggable(Pluggable pluggable) {
    if (_activatedPluggable?.name == pluggable.name) {
      _activatedPluggable = null;
    }
  }
}
