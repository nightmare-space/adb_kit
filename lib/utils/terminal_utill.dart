import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

Map<String, String> envir() {
  Map<String, String> envir = RuntimeEnvir.envir();
  if (GetPlatform.isMobile) {
    envir['HOME'] = RuntimeEnvir.binPath;
  }
  envir['TERMUX_PREFIX'] = RuntimeEnvir.usrPath;
  envir['TERM'] = 'xterm-256color';
  return envir;
}
