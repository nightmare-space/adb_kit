import 'package:dart_adb/adb.dart';
import 'package:global_repository/global_repository_dart.dart';
import 'package:adb_util/src/adb_command.dart' as ac;
import 'package:signale/signale.dart';

class ADBDevice {
  ADBDevice(this.serial, this.stat);
  static ADBDevice parse(String data) {
    final tmp = data.trim().split(RegExp('\\s+'));
    final device = ADBDevice(tmp.first, tmp.last);
    return device;
  }

  /// ip or serial
  final String serial;

  /// ro.product.model or ro.product.marketname(xiaomi)
  String? productModel;

  /// connect stat
  String stat;

  /// /data/local/tmp/nid
  String nid = '';

  /// 判断 serial 是否是 ipv4/ipv6
  /// check serial is ipv4/ipv6
  bool get isNetworkDevice {
    return serial.contains(':');
  }

  /// for example:
  /// [240e:39c:3f:7300:278f:fd9a:c63f:cd1c]:5555 will get [240e:39c:3f:7300:278f:fd9a:c63f:cd1c]
  /// note: ipv6 address will be wrapped in square brackets
  /// 192.168.31.111:5555 will get 192.168.31.111
  String extractIp() {
    return removePort(serial);
  }

  String removePort(String address) {
    // 检查是否包含端口
    if (address.contains(':')) {
      // 如果是IPv6地址，端口前会有一个单独的冒号
      if (address.contains('[') && address.contains(']')) {
        return '${address.split(']:')[0]}]';
      } else {
        // IPv4地址或没有方括号的IPv6地址
        return address.split(':')[0];
      }
    }
    // 如果不包含端口，直接返回原地址
    return address;
  }

  String extractPort() {
    return serial.split(':').last;
  }

  bool get isConnect => stat == 'device';

  String? password;

  @override
  String toString() {
    return 'ADBDevice{serial: $serial, stat: $stat model: $productModel nid: $nid}';
  }

  @override
  bool operator ==(Object other) {
    if (other is ADBDevice) {
      return other.serial == serial;
    }
    return false;
  }

  @override
  int get hashCode => serial.hashCode;

  Future<bool> getSystemBool({
    required String key,
  }) async {
    return await ac.getSystemBool(
      serial: serial,
      key: key,
      password: password,
    );
  }

  // setSystem
  Future<void> setSystem({
    required String key,
    required String value,
  }) async {
    await ac.setSystem(
      serial: serial,
      key: key,
      value: value,
      password: password,
    );
  }

  Future<String> runShell(
    String command,
  ) async {
    return ac.runShell(
      serial: serial,
      command: command,
      password: password,
    );
  }

  // getProp
  Future<String> getProp({
    required String key,
  }) async {
    return ac.getProp(
      serial: serial,
      key: key,
      password: password,
    );
  }

  // asyncExec
  // Future<void> asyncExec(String command) async {
  //   await ac.asyncExec(
  //     serial: serial,
  //     command: command,
  //     password: password,
  //   );
  // }
}

///
class ADBDeviceFromDartAPI extends ADBDevice {
  ADBDeviceFromDartAPI(super.serial, super.stat);
  late ADBIO adbio;

  @override
  String toString() {
    return 'ADBDeviceFromDartAPI{serial: $serial, stat: $stat model: $productModel nid: $nid}';
  }

  @override
  Future<bool> getSystemBool({
    required String key,
    String? password,
  }) async {
    String result = await adbio.adbShell('settings get system $key');
    Log.e('result -> $result');
    return result.trim() == '1';
  }

  @override
  Future<void> setSystem({
    required String key,
    required String value,
    String? password,
  }) async {
    await adbio.adbShell('settings put system $key $value');
  }

  @override
  Future<String> runShell(
    String command,
  ) async {
    return (await adbio.adbShell(command)).trim();
  }

  @override
  Future<String> getProp({
    required String key,
    String? password,
  }) async {
    return await adbio.adbShell('getprop $key');
  }
}
