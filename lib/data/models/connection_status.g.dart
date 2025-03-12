// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConnectionStatusImpl _$$ConnectionStatusImplFromJson(
        Map<String, dynamic> json) =>
    _$ConnectionStatusImpl(
      isConnected: json['isConnected'] as bool,
      connectionType: json['connectionType'] as String? ?? 'unknown',
      lastChecked: json['lastChecked'] == null
          ? null
          : DateTime.parse(json['lastChecked'] as String),
    );

Map<String, dynamic> _$$ConnectionStatusImplToJson(
        _$ConnectionStatusImpl instance) =>
    <String, dynamic>{
      'isConnected': instance.isConnected,
      'connectionType': instance.connectionType,
      'lastChecked': instance.lastChecked?.toIso8601String(),
    };
