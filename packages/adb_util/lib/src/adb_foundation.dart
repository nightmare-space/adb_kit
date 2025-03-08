import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:global_repository/global_repository_dart.dart';
import 'package:signale/signale.dart';

Map<String, String> adbEnvir() {
  Map<String, String> envir = RuntimeEnvir.envir();
  envir['TMPDIR'] = RuntimeEnvir.binPath;
  // ADB_MDNS=0 can fix rokid bug(adb will crash when mDNS is enabled)
  envir['ADB_MDNS'] = '0';
  envir['ADB_MDNS_AUTO_CONNECT'] = '0';
  // ADB_EMU=0
  envir['ADB_EMU'] = '0';
  if (Platform.isAndroid) {
    envir['PREFIX'] = RuntimeEnvir.usrPath;
    envir['HOME'] = RuntimeEnvir.homePath;
  }
  envir['LD_LIBRARY_PATH'] = RuntimeEnvir.binPath;
  envir['RUST_LOG'] = 'debug';
  // envir['RUST_LOG'] = 'trace';
  return envir;
}

Future<String> exec(
  String cmd, {
  String? password,
  bool useProcessRun = false,
}) async {
  if (useProcessRun) {
    return await execWRWS(cmd);
  }
  String result = await execWSWS(cmd, password: password);
  return result;
}

/// exec with args(List)
Future<String> execWL(
  List<String> args, {
  String? password,
  bool useProcessRun = false,
}) async {
  if (useProcessRun) {
    return await execWRWL(args);
  }
  String result = await execWSWL(args, password: password);
  return result;
}

// with process start
Future<String> execWSWS(String cmd, {String? password}) {
  final List<String> args = cmd.split(' ');
  return execWSWL(args, password: password);
}

Future<String> execWSWL(List<String> args, {String? password}) async {
  Log.i('adb cmd -> ${args.join(' ')}');
  Process process = await Process.start(
    args[0],
    args.sublist(1),
    environment: adbEnvir(),
    includeParentEnvironment: true,
    runInShell: Platform.isWindows ? true : false,
  );
  StringBuffer buffer = StringBuffer();
  Completer<String> completer = Completer();
  final converter = SystemEncoding().decoder;

  process.stdout.transform(converter).listen((data) {
    buffer.write(data);
  });
  process.stderr.transform(converter).listen((data) {
    // check verify success 是哪儿出来的
    if (data.contains('please input verify password')) {
      if (password == null) {
        Log.e('password is null');
        completer.completeError('password is null');
        process.kill();
      } else {
        process.stdin.add(utf8.encode('$password\n'));
      }
    } else if (data.contains('verify success')) {
      // do nothing
    } else {
      completer.completeError(data.trim());
    }
  });
  process.exitCode.then((int code) {
    if (!completer.isCompleted) {
      completer.complete('$buffer'.trim());
    }
  });
  return completer.future;
}

/// with process run and string cmd
Future<String> execWRWS(String cmd) async {
  final List<String> args = cmd.split(' ');
  return execWRWL(args);
}

/// with process run and list cmd
Future<String> execWRWL(List<String> args) async {
  ProcessResult result = await Process.run(
    args[0],
    args.sublist(1),
    environment: adbEnvir(),
    includeParentEnvironment: true,
    // TODO check runInShell is necessary
    runInShell: Platform.isWindows ? true : false,
    stdoutEncoding: utf8,
    stderrEncoding: utf8,
  );
  // var decodedOutput = const SystemEncoding().decode(result.stdout);
  // Log.e('decodedOutput -> $decodedOutput');
  if (result.stderr.isNotEmpty) {
    throw '${result.stderr}'.trim();
  }
  return '${result.stdout}'.trim();
}
