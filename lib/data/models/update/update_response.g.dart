// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_UpdateResponse _$$_UpdateResponseFromJson(Map<String, dynamic> json) =>
    _$_UpdateResponse(
      newupdate: json['newupdate'] as bool,
      version: json['version'] as String,
      download: json['download'] as String,
    );

Map<String, dynamic> _$$_UpdateResponseToJson(_$_UpdateResponse instance) =>
    <String, dynamic>{
      'newupdate': instance.newupdate,
      'version': instance.version,
      'download': instance.download,
    };
