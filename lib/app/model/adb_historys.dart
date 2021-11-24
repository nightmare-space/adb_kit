import 'dart:convert';

T asT<T>(dynamic value) {
  if (value is T) {
    return value;
  }
  return null;
}

class ADBHistorys {
  ADBHistorys({
    this.data,
  });

  factory ADBHistorys.fromJson(Map<String, dynamic> jsonRes) {
    if (jsonRes == null) {
      return null;
    }

    final List<Data> data = jsonRes['data'] is List ? <Data>[] : null;
    if (data != null) {
      for (final dynamic item in jsonRes['data']) {
        if (item != null) {
          data.add(Data.fromJson(asT<Map<String, dynamic>>(item)));
        }
      }
    }
    return ADBHistorys(
      data: data,
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

  ADBHistorys clone() => ADBHistorys.fromJson(
      asT<Map<String, dynamic>>(jsonDecode(jsonEncode(this))));
}

class Data {
  Data({
    this.address,
    this.port,
    this.connectTime,
    this.name,
  });

  factory Data.fromJson(Map<String, dynamic> jsonRes) => jsonRes == null
      ? null
      : Data(
          address: asT<String>(jsonRes['address']),
          port: asT<String>(jsonRes['port']),
          connectTime: asT<String>(jsonRes['connect_time']),
          name: asT<String>(jsonRes['name']),
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

  Data clone() =>
      Data.fromJson(asT<Map<String, dynamic>>(jsonDecode(jsonEncode(this))));
}

extension TimeExtension on DateTime {
  String getTimeString() {
    return '$year-$month-$day $hour:$minute:$second';
  }
}
