// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'update_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

UpdateResponse _$UpdateResponseFromJson(Map<String, dynamic> json) {
  return _UpdateResponse.fromJson(json);
}

/// @nodoc
mixin _$UpdateResponse {
  bool get newupdate => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;
  String get download => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UpdateResponseCopyWith<UpdateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UpdateResponseCopyWith<$Res> {
  factory $UpdateResponseCopyWith(
          UpdateResponse value, $Res Function(UpdateResponse) then) =
      _$UpdateResponseCopyWithImpl<$Res>;
  $Res call({bool newupdate, String version, String download});
}

/// @nodoc
class _$UpdateResponseCopyWithImpl<$Res>
    implements $UpdateResponseCopyWith<$Res> {
  _$UpdateResponseCopyWithImpl(this._value, this._then);

  final UpdateResponse _value;
  // ignore: unused_field
  final $Res Function(UpdateResponse) _then;

  @override
  $Res call({
    Object? newupdate = freezed,
    Object? version = freezed,
    Object? download = freezed,
  }) {
    return _then(_value.copyWith(
      newupdate: newupdate == freezed
          ? _value.newupdate
          : newupdate // ignore: cast_nullable_to_non_nullable
              as bool,
      version: version == freezed
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      download: download == freezed
          ? _value.download
          : download // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_UpdateResponseCopyWith<$Res>
    implements $UpdateResponseCopyWith<$Res> {
  factory _$$_UpdateResponseCopyWith(
          _$_UpdateResponse value, $Res Function(_$_UpdateResponse) then) =
      __$$_UpdateResponseCopyWithImpl<$Res>;
  @override
  $Res call({bool newupdate, String version, String download});
}

/// @nodoc
class __$$_UpdateResponseCopyWithImpl<$Res>
    extends _$UpdateResponseCopyWithImpl<$Res>
    implements _$$_UpdateResponseCopyWith<$Res> {
  __$$_UpdateResponseCopyWithImpl(
      _$_UpdateResponse _value, $Res Function(_$_UpdateResponse) _then)
      : super(_value, (v) => _then(v as _$_UpdateResponse));

  @override
  _$_UpdateResponse get _value => super._value as _$_UpdateResponse;

  @override
  $Res call({
    Object? newupdate = freezed,
    Object? version = freezed,
    Object? download = freezed,
  }) {
    return _then(_$_UpdateResponse(
      newupdate: newupdate == freezed
          ? _value.newupdate
          : newupdate // ignore: cast_nullable_to_non_nullable
              as bool,
      version: version == freezed
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
      download: download == freezed
          ? _value.download
          : download // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_UpdateResponse implements _UpdateResponse {
  const _$_UpdateResponse(
      {required this.newupdate, required this.version, required this.download});

  factory _$_UpdateResponse.fromJson(Map<String, dynamic> json) =>
      _$$_UpdateResponseFromJson(json);

  @override
  final bool newupdate;
  @override
  final String version;
  @override
  final String download;

  @override
  String toString() {
    return 'UpdateResponse(newupdate: $newupdate, version: $version, download: $download)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UpdateResponse &&
            const DeepCollectionEquality().equals(other.newupdate, newupdate) &&
            const DeepCollectionEquality().equals(other.version, version) &&
            const DeepCollectionEquality().equals(other.download, download));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(newupdate),
      const DeepCollectionEquality().hash(version),
      const DeepCollectionEquality().hash(download));

  @JsonKey(ignore: true)
  @override
  _$$_UpdateResponseCopyWith<_$_UpdateResponse> get copyWith =>
      __$$_UpdateResponseCopyWithImpl<_$_UpdateResponse>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_UpdateResponseToJson(
      this,
    );
  }
}

abstract class _UpdateResponse implements UpdateResponse {
  const factory _UpdateResponse(
      {required final bool newupdate,
      required final String version,
      required final String download}) = _$_UpdateResponse;

  factory _UpdateResponse.fromJson(Map<String, dynamic> json) =
      _$_UpdateResponse.fromJson;

  @override
  bool get newupdate;
  @override
  String get version;
  @override
  String get download;
  @override
  @JsonKey(ignore: true)
  _$$_UpdateResponseCopyWith<_$_UpdateResponse> get copyWith =>
      throw _privateConstructorUsedError;
}
