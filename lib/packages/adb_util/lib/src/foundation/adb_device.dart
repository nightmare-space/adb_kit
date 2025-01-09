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
}
