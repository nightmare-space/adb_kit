import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
part 'adb_historys.g.dart';

@JsonSerializable()
class ADBHistorys {
  ADBHistorys({
    required this.data,
  });

  List<ADBHistory> data;
  factory ADBHistorys.fromJson(Map<String, dynamic> json) => _$ADBHistorysFromJson(json);
  Map<String, dynamic> toJson() => _$ADBHistorysToJson(this);
  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

@JsonSerializable()
class ADBHistory {
  ADBHistory({
    required this.address,
    required this.port,
    required this.connectTime,
    required this.name,
    required this.uniqueId,
  });

  String address;
  String port;
  String connectTime;
  String name;
  String uniqueId;

  factory ADBHistory.fromJson(Map<String, dynamic> json) => _$ADBHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$ADBHistoryToJson(this);
}

extension TimeExtension on DateTime {
  String getTimeString() {
    return '$year-$month-$day $hour:$minute:$second';
  }
}
