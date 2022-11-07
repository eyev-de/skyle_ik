// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'update_arguments.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

UpdateArguments _$UpdateArgumentsFromJson(Map<String, dynamic> json) {
  return _UpdateArguments.fromJson(json);
}

/// @nodoc
mixin _$UpdateArguments {
  String get version => throw _privateConstructorUsedError;
  BigInt get serial => throw _privateConstructorUsedError;
  bool? get beta => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateArgumentsCopyWith<UpdateArguments> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateArgumentsCopyWith<$Res> {
  factory $UpdateArgumentsCopyWith(
          UpdateArguments value, $Res Function(UpdateArguments) then) =
      _$UpdateArgumentsCopyWithImpl<$Res>;
  $Res call({String version, BigInt serial, bool? beta});
}

/// @nodoc
class _$UpdateArgumentsCopyWithImpl<$Res>
    implements $UpdateArgumentsCopyWith<$Res> {
  _$UpdateArgumentsCopyWithImpl(this._value, this._then);

  final UpdateArguments _value;
  // ignore: unused_field
  final $Res Function(UpdateArguments) _then;

  @override
  $Res call({
    Object? version = freezed,
    Object? serial = freezed,
    Object? beta = freezed,
  }) {
    return _then(_value.copyWith(
      version: version == freezed
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      serial: serial == freezed
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as BigInt,
      beta: beta == freezed
          ? _value.beta
          : beta // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
abstract class _$$_UpdateArgumentsCopyWith<$Res>
    implements $UpdateArgumentsCopyWith<$Res> {
  factory _$$_UpdateArgumentsCopyWith(
          _$_UpdateArguments value, $Res Function(_$_UpdateArguments) then) =
      __$$_UpdateArgumentsCopyWithImpl<$Res>;
  @override
  $Res call({String version, BigInt serial, bool? beta});
}

/// @nodoc
class __$$_UpdateArgumentsCopyWithImpl<$Res>
    extends _$UpdateArgumentsCopyWithImpl<$Res>
    implements _$$_UpdateArgumentsCopyWith<$Res> {
  __$$_UpdateArgumentsCopyWithImpl(
      _$_UpdateArguments _value, $Res Function(_$_UpdateArguments) _then)
      : super(_value, (v) => _then(v as _$_UpdateArguments));

  @override
  _$_UpdateArguments get _value => super._value as _$_UpdateArguments;

  @override
  $Res call({
    Object? version = freezed,
    Object? serial = freezed,
    Object? beta = freezed,
  }) {
    return _then(_$_UpdateArguments(
      version: version == freezed
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      serial: serial == freezed
          ? _value.serial
          : serial // ignore: cast_nullable_to_non_nullable
              as BigInt,
      beta: beta == freezed
          ? _value.beta
          : beta // ignore: cast_nullable_to_non_nullable
              as bool?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_UpdateArguments implements _UpdateArguments {
  const _$_UpdateArguments(
      {required this.version, required this.serial, this.beta});

  factory _$_UpdateArguments.fromJson(Map<String, dynamic> json) =>
      _$$_UpdateArgumentsFromJson(json);

  @override
  final String version;
  @override
  final BigInt serial;
  @override
  final bool? beta;

  @override
  String toString() {
    return 'UpdateArguments(version: $version, serial: $serial, beta: $beta)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UpdateArguments &&
            const DeepCollectionEquality().equals(other.version, version) &&
            const DeepCollectionEquality().equals(other.serial, serial) &&
            const DeepCollectionEquality().equals(other.beta, beta));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(version),
      const DeepCollectionEquality().hash(serial),
      const DeepCollectionEquality().hash(beta));

  @JsonKey(ignore: true)
  @override
  _$$_UpdateArgumentsCopyWith<_$_UpdateArguments> get copyWith =>
      __$$_UpdateArgumentsCopyWithImpl<_$_UpdateArguments>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UpdateArgumentsToJson(
      this,
    );
  }
}

abstract class _UpdateArguments implements UpdateArguments {
  const factory _UpdateArguments(
      {required final String version,
      required final BigInt serial,
      final bool? beta}) = _$_UpdateArguments;

  factory _UpdateArguments.fromJson(Map<String, dynamic> json) =
      _$_UpdateArguments.fromJson;

  @override
  String get version;
  @override
  BigInt get serial;
  @override
  bool? get beta;
  @override
  @JsonKey(ignore: true)
  _$$_UpdateArgumentsCopyWith<_$_UpdateArguments> get copyWith =>
      throw _privateConstructorUsedError;
}
