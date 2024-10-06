// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adb_historys.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ADBHistorys _$ADBHistorysFromJson(Map<String, dynamic> json) => ADBHistorys(
      data: (json['data'] as List<dynamic>)
          .map((e) => ADBHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ADBHistorysToJson(ADBHistorys instance) =>
    <String, dynamic>{
      'data': instance.data,
    };

ADBHistory _$ADBHistoryFromJson(Map<String, dynamic> json) => ADBHistory(
      address: json['address'] as String,
      port: json['port'] as String,
      connectTime: json['connectTime'] as String,
      name: json['name'] as String,
      uniqueId: json['uniqueId'] as String,
    );

Map<String, dynamic> _$ADBHistoryToJson(ADBHistory instance) =>
    <String, dynamic>{
      'address': instance.address,
      'port': instance.port,
      'connectTime': instance.connectTime,
      'name': instance.name,
      'uniqueId': instance.uniqueId,
    };
