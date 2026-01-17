import 'dart:io';
import 'package:crypto/crypto.dart';

Future<String> getFileMD5(String path) async {
  final file = File(path);
  if (!file.existsSync()) {
    throw Exception('File not found: $path');
  }

  final bytes = await file.readAsBytes();
  final digest = md5.convert(bytes);
  return digest.toString();
}
