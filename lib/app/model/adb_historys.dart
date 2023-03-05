import 'dart:convert';

T? asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

class ADBHistorys {
  ADBHistorys({
    required this.data,
  });

  factory ADBHistorys.fromJson(Map<String, dynamic> json) {
    final List<Data>? data = json['data'] is List ? <Data>[] : null;
    if (data != null) {
      for (final dynamic item in json['data']!) {
        if (item != null) {
          data.add(Data.fromJson(asT<Map<String, dynamic>>(item)!));
        }
      }
    }
    return ADBHistorys(
      data: data!,
    );
  }

  List<Data> data;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'data': data,
      };
}

class Data {
  Data({
    required this.address,
    required this.port,
    required this.connectTime,
    required this.name,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        address: asT<String>(json['address'])!,
        port: asT<String>(json['port'])!,
        connectTime: asT<String>(json['connect_time'])!,
        name: asT<String>(json['name'])!,
      );

  String address;
  String port;
  String connectTime;
  String name;

  @override
  String toString() {
    return jsonEncode(this);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'address': address,
        'port': port,
        'connect_time': connectTime,
        'name': name,
      };
}
extension TimeExtension on DateTime {
  String getTimeString() {
    return '$year-$month-$day $hour:$minute:$second';
  }
}