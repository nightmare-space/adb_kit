import 'package:flutter/services.dart';

MethodChannel _channel = const MethodChannel('adb');
typedef MethodHandler = void Function(MethodCall call);

class PluginUtil {
  PluginUtil._();
  static bool _init = false;
  static List<MethodHandler> handlers = [];
  static Future<void> addHandler(MethodHandler handler) async {
    handlers.add(handler);
    if (!_init) {
      _setMethodCallHandler();
    }
  }

  static Future<void> removeHandler(MethodHandler handler) async {
    if (handlers.contains(handler)) {
      handlers.remove(handler);
    }
  }

  static void _setMethodCallHandler() {
    _channel.setMethodCallHandler((call) async {
      for (final MethodHandler handler in handlers) {
        handler(call);
      }
    });
    _init = true;
  }

  static void writeToOTG(String data) {
    _channel.invokeMethod('write', data);
  }

  static Future<void> pushToOTG(String local, String remote) async {
    await _channel.invokeMethod('push', [local, remote]);
  }

  static Future<String?> execCmd(String cmd) async {
    return await _channel.invokeMethod('exec_cmd', cmd);
  }

  static Future<String?> changeNetDbugStatus(int port) async {
    return await _channel.invokeMethod('tcpip', port);
  }
}
