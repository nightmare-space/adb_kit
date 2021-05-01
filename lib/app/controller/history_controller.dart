import 'dart:io';
import 'package:adb_tool/config/config.dart';
import 'package:signale/signale.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:global_repository/global_repository.dart';

// 考虑是否加时间
class AdbEntity {
  AdbEntity(this.ip, this.port, this.dateTime);

  AdbEntity.parse(String data) {
    final List<String> tmp = data.split('<>');
    ip = tmp[0];
    port = tmp[1];
    dateTime = DateTime.parse(tmp[2]);
  }
  String ip;
  String port;
  DateTime dateTime;
  @override
  int get hashCode => '$ip$port'.hashCode;
  String getTimeString() {
    return '${dateTime.year}-${dateTime.month}-${dateTime.day} ${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  String getLocalString() {
    return '$ip<>$port<>$dateTime';
  }

  @override
  bool operator ==(dynamic other) {
    // 判断是否是非
    if (other is! AdbEntity) {
      return false;
    }
    if (other is AdbEntity) {
      final AdbEntity adbEntity = other;
      return ip + port == adbEntity.ip + adbEntity.port;
    }
    return false;
  }

  @override
  String toString() {
    return '$ip<>$port<>${getTimeString()}';
  }
}

class HistoryController extends GetxController {
  HistoryController() {
    if (!Config.localDir.existsSync()) {
      Config.localDir.createSync(
        recursive: true,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    Log.w('$this init');
    readLocalStorage();
  }

  @override
  void onReady() {
    super.onReady();
    Log.w('$this onReady');
  }

  Set<AdbEntity> adbEntitys = {};
  Future<void> saveToLocal() async {
    final StringBuffer buffer = StringBuffer();
    for (final AdbEntity adbEntity in adbEntitys) {
      buffer.write('${adbEntity.getLocalString()}\n');
    }
    Config.historySaveFile.writeAsString(buffer.toString().trim());
  }

  Future<void> readLocalStorage() async {
    if (!Config.historySaveFile.existsSync()) {
      return;
    }
    String data = await Config.historySaveFile.readAsString();
    data = data.trim();
    for (final String line in data.split('\n')) {
      adbEntitys.add(AdbEntity.parse(line));
    }
    update();
  }

  void addAdbEntity(AdbEntity adbEntity) {
    Log.d('添加 $adbEntity');
    adbEntitys.add(adbEntity);
    Log.d('当前 adbEntitys => $adbEntitys');
    saveToLocal();
  }
}
