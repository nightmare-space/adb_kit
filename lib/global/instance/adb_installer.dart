import 'dart:io';

import 'package:adb_kit/config/config.dart';
import 'package:adb_kit/utils/utils.dart';
import 'package:adb_library/adb_library.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:global_repository/global_repository.dart';

List<String> androidFiles = [
  'libadb.so',
  'libtermux-api.so',
  'libtermux-callback.so',
  'libtermux-toast.so',
  'libtermux-usb.so',
];

const List<String> globalFiles = [
  'app_server',
];

class ADBInstaller {
  /// 复制一堆执行文件
  static Future<void> installAdbToEnvir({
    List<String> globalFiles = globalFiles,
  }) async {
    if (kIsWeb) {
      return;
    }
    if (GetPlatform.isAndroid) {
      String? libPath = await AdbLibrary.getLibPath();
      for (int i = 0; i < androidFiles.length; i++) {
        // when android target sdk > 28
        // cannot execute file in /data/data/com.xxx/files/usr/bin
        // so we need create a link to /data/data/com.xxx/files/usr/bin
        final sourcePath = '$libPath/${androidFiles[i]}';
        String fileName = androidFiles[i].replaceAll(RegExp('^lib|.so'), '');
        String filePath = '${RuntimeEnvir.binPath}/$fileName';
        // custom path, termux-api will invoke
        if (fileName == 'termux-callback') {
          filePath = '${RuntimeEnvir.usrPath}/libexec/termux-callback';
        }
        File file = File(filePath);
        FileSystemEntityType type = await FileSystemEntity.type(filePath);
        Log.i('$fileName type -> $type');
        if (type != FileSystemEntityType.notFound && type != FileSystemEntityType.link) {
          // old version adb is plain file
          Log.i('find plain file -> $fileName, delete it');
          await file.delete();
        }
        Link link = Link(filePath);
        if (link.existsSync()) {
          link.deleteSync();
        }
        try {
          Log.i('create link -> $fileName');
          link.createSync(sourcePath);
        } catch (e) {
          Log.e('installAdbToEnvir error -> $e');
        }
      }
      Directory(RuntimeEnvir.binPath).list().listen((event) {
        Log.i('-> $event');
        String fileNmae = event.path.split('/').last;
        if (fileNmae.endsWith('.so')) {
          // old version create some so file
          Log.i('delete -> ${event.path}');
          event.deleteSync();
        }
      });
    }
    await AssetsManager.copyFiles(
      localPath: '${RuntimeEnvir.binPath}/',
      macOS: [],
      global: globalFiles,
      package: Config.flutterPackage,
      forceCopy: true,
    );
  }
}
