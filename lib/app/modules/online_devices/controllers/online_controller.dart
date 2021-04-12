import 'package:get/get.dart';

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
  @override
  void onInit() {
    print('init了');
    super.onInit();
  }

  @override
  void onReady() {
    //
    // int a = 0;
    print('onReady');
    super.onReady();
  }

  @override
  void onClose() {}

  void addDevices(DeviceEntity devices) {
    // this.addListener(() { });
    // removeListener(() { });
    // notifyChildrens();
    update();
    if (!list.contains(devices)) {
      list.add(devices);
    }
  }
}
