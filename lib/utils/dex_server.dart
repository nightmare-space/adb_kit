import 'dart:async';
import 'package:android_api_server_client/android_api_server_client.dart';
import 'package:adb_util/adb_util_flutter.dart';

class DexServer {
  DexServer._();

  static Future<AASClient> startServer(String devicesId) async {
    return AndroidAPIServerStarter.startServer(devicesId);
  }
}
