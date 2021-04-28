import 'dart:io';
import 'package:adb_tool/config/config.dart';
import 'package:custom_log/custom_log.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:global_repository/global_repository.dart';

// 考虑是否加时间
class AdbEntity {
  AdbEntity(this.ip, this.port, this.dateTime);

  final String ip;
  final String port;
  final DateTime dateTime;
  @override
  int get hashCode => '$ip$port'.hashCode;

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
    return '$ip:$port';
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
  Set<AdbEntity> adbEntitys = {};
  Future<void> saveToLocal() async {
    final StringBuffer buffer = StringBuffer();
    for (final AdbEntity adbEntity in adbEntitys) {
      buffer.write('$adbEntity\n');
    }
    Config.historySaveFile.writeAsString(buffer.toString().trim());
  }

  void readLocalStorage() {}
  void addAdbEntity(AdbEntity adbEntity) {
    Log.d('添加 $adbEntity');
    adbEntitys.add(adbEntity);
    Log.d('当前 adbEntitys => $adbEntitys');
    saveToLocal();
  }
}
