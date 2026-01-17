import 'dart:io';
import 'package:global_repository/global_repository_dart.dart' hide exec;
import 'package:signale/signale.dart';

import '../../adb_util.dart';

Future<String> startServer() async {
  Directory(RuntimeEnvir.binPath).createSync(recursive: true);
  Directory(RuntimeEnvir.homePath).createSync(recursive: true);
  return await exec('$adb start-server', useProcessRun: true);
}

Future<String> enableTcp5555({
  required String serial,
  String? password,
}) {
  return exec('$adb -s $serial tcpip 5555', useProcessRun: true);
}
