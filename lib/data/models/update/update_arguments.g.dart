// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_arguments.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_UpdateArguments _$$_UpdateArgumentsFromJson(Map<String, dynamic> json) =>
    _$_UpdateArguments(
      version: json['version'] as String,
      serial: BigInt.parse(json['serial'] as String),
      beta: json['beta'] as bool?,
    );

Map<String, dynamic> _$$_UpdateArgumentsToJson(_$_UpdateArguments instance) =>
    <String, dynamic>{
      'version': instance.version,
      'serial': instance.serial.toString(),
      'beta': instance.beta,
    };
