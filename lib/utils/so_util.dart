import 'package:flutter/services.dart';

Future<String> getLibPath() async {
  String libPath = await const MethodChannel('adb').invokeMethod(
    'get_lib_path',
  );
  return libPath;
}
