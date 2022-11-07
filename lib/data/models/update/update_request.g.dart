// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_UpdateRequest _$$_UpdateRequestFromJson(Map<String, dynamic> json) =>
    _$_UpdateRequest(
      version: json['version'] as String,
      serial: BigInt.parse(json['serial'] as String),
      beta: json['beta'] as bool,
    );

Map<String, dynamic> _$$_UpdateRequestToJson(_$_UpdateRequest instance) =>
    <String, dynamic>{
      'version': instance.version,
      'serial': instance.serial.toString(),
      'beta': instance.beta,
    };
