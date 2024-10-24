import 'package:adb_kit/core/interface/pluggable.dart';

/// A singleton class that manages all the plugins registered in the app.
class PluginManager {
  static PluginManager? _instance;

  Map<String, ADBKITPlugin> get pluginsMap => _pluginsMap;

  final Map<String, ADBKITPlugin> _pluginsMap = {};

  ADBKITPlugin? _activatedPluggable;
  String? get activatedPluggableName => _activatedPluggable?.name;

  static PluginManager get instance {
    _instance ??= PluginManager._();
    return _instance!;
  }

  PluginManager._();

  /// Register a single [plugin]
  void registerADBPlugin(ADBKITPlugin plugin) {
    if (plugin.id.isEmpty) {
      return;
    }
    _pluginsMap[plugin.id] = plugin;
  }

  void registerDrawerPage(ADBKITPlugin plugin) {
    // TODO
    // if (plugin.name.isEmpty) {
    //   return;
    // }
    // _pluginsMap[plugin.name] = plugin;
  }

  /// Register multiple [plugins]
  void registerAll(List<ADBKITPlugin> plugins) {
    for (final plugin in plugins) {
      registerADBPlugin(plugin);
    }
  }

  void activatePluggable(ADBKITPlugin pluggable) {
    _activatedPluggable = pluggable;
  }

  void deactivatePluggable(ADBKITPlugin pluggable) {
    if (_activatedPluggable?.name == pluggable.name) {
      _activatedPluggable = null;
    }
  }
}
