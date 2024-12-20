import 'package:global_repository/global_repository_dart.dart';
import 'package:flutter/foundation.dart';

Future<String> asyncExec(String cmd) async {
  return await compute(execCmdForIsolate, Arg(RuntimeEnvir.packageName, cmd));
}

Future<String> execCmdForIsolate(Arg arg) async {
  RuntimeEnvir.initEnvirWithPackageName(arg.package!);
  return await exec(arg.cmd);
}

class Arg {
  final String? package;
  final String cmd;

  Arg(this.package, this.cmd);
}
