import 'dart:convert';

import 'package:adb_kit/app/model/adb_historys.dart';
import 'package:adb_kit/config/config.dart';
import 'package:get/get.dart';

class AdbEntity {
  AdbEntity(this.ip, this.port, this.dateTime);

  AdbEntity.parse(String data) {
    final List<String> tmp = data.split('<>');
    ip = tmp[0];
    port = tmp[1];
    dateTime = DateTime.parse(tmp[2]);
  }
  String? ip;
  String? port;
  DateTime? dateTime;
  @override
  int get hashCode => '$ip$port'.hashCode;
  String getTimeString() {
    return '${dateTime!.year}-${dateTime!.month}-${dateTime!.day} ${dateTime!.hour}:${dateTime!.minute}:${dateTime!.second}';
  }

  String getLocalString() {
    return '$ip<>$port<>$dateTime';
  }

  @override
  bool operator ==(Object other) {
    // 判断是否是非
    if (other is! AdbEntity) {
      return false;
    }
    final AdbEntity adbEntity = other;
    return ip! + port! == adbEntity.ip! + adbEntity.port!;
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
  static void updateHistory({
    String? address,
    String? port,
    String? name,
  }) {
    final HistoryController historyController = Get.find();
    historyController._updateHistory(
      Data(
        address: address!,
        port: port ?? '5555',
        connectTime: DateTime.now().toString(),
        name: name!,
      ),
    );
  }

  ADBHistorys adbHistorys = ADBHistorys(data: []);

  @override
  void onInit() {
    super.onInit();
    // Log.w('$this init');
    readLocalStorage();
  }


  Future<void> saveToLocal() async {
    Config.historySaveFile.writeAsString(adbHistorys.toString());
  }

  Future<void> readLocalStorage() async {
    if (!Config.historySaveFile.existsSync()) {
      return;
    }
    final String data = await Config.historySaveFile.readAsString();
    try {
      adbHistorys = ADBHistorys.fromJson(jsonDecode(data) as Map<String, dynamic>);
      sort();
    } catch (e) {
      Config.historySaveFile.delete();
    }
    update();
  }

  void sort() {
    adbHistorys.data.sort((a, b) {
      return DateTime.parse(b.connectTime).compareTo(
        DateTime.parse(a.connectTime),
      );
    });
  }

  void removeHis(int index) {
    adbHistorys.data.removeAt(index);
    saveToLocal();
  }

  void _updateHistory(Data data) {
    try {
      final Data preData = adbHistorys.data.firstWhere(
        (element) {
          return element.address == data.address;
        },
      );
      preData.connectTime = data.connectTime;
      preData.name = data.name;
    } catch (e) {
      adbHistorys.data.add(data);
    }
    saveToLocal();
  }
}
