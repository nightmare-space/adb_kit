import 'dart:io';

import 'package:global_repository/global_repository.dart';

Map<String, String> envir() {
  Map<String, String> envir;
  envir = Map.from(Platform.environment);
  envir['HOME'] = RuntimeEnvir.homePath;
  envir['TERMUX_PREFIX'] = RuntimeEnvir.usrPath;
  envir['TERM'] = 'xterm-256color';
  envir['PATH'] = RuntimeEnvir.path;
  return envir;
}
