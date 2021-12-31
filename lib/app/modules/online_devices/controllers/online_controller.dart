import 'package:adb_tool/app/controller/devices_controller.dart';
import 'package:adbutil/adbutil.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_workers/utils/debouncer.dart';
import 'package:global_repository/global_repository.dart';

class DeviceEntity {
  DeviceEntity(this.unique, this.address);
  final String unique;
  final String address;
  @override
  String toString() {
    return 'unique:$unique address:$address';
  }

  @override
  bool operator ==(dynamic other) {
    // 判断是否是非
    if (other is! DeviceEntity) {
      return false;
    }
    if (other is DeviceEntity) {
      return other.address == address;
    }
    return false;
  }

  @override
  int get hashCode => address.hashCode;
}

class OnlineController extends GetxController {
  final list = <DeviceEntity>[].obs;
  final Debouncer _debouncer = Debouncer(
    delay: const Duration(
      milliseconds: 800,
    ),
  );
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  Future<void> updateDevices(DeviceEntity devices) async {
    AdbResult result;
    try {
      result = await AdbUtil.connectDevices(
        devices.address,
      );
      showToast('自动连接${devices.unique}成功');
    } on AdbException catch (e) {
      // Log.v(e.message);
    }
    if (!list.contains(devices)) {
      list.add(devices);
    } else {
      // list.firstWhere((element) =>element.address== devices.address);
    }

    _debouncer.call(() {
      removeOnlineItem(devices);
    });
    update();
  }

  void removeOnlineItem(DeviceEntity devices) {
    list.remove(devices);
    update();
    // Log.w('removeOnlineItem -> $list');
  }
}
