import 'package:get/get_state_manager/get_state_manager.dart';

class AdbEntity {
  AdbEntity(this.ip, this.port);

  final String ip;
  final String port;

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
  String storePath = '';
  List<AdbEntity> adbEntitys = [];
  Future<void> saveToLocal() async {
    final StringBuffer buffer = StringBuffer();
    for (final AdbEntity adbEntity in adbEntitys) {
      buffer.write('$adbEntity\n');
    }
  }
}
