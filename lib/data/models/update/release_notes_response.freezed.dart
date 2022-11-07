// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'release_notes_response.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

ReleaseNotesResponse _$ReleaseNotesResponseFromJson(Map<String, dynamic> json) {
  return _ReleaseNotesResponse.fromJson(json);
}

/// @nodoc
mixin _$ReleaseNotesResponse {
  String get notes => throw _privateConstructorUsedError;
  String get version => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReleaseNotesResponseCopyWith<ReleaseNotesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReleaseNotesResponseCopyWith<$Res> {
  factory $ReleaseNotesResponseCopyWith(ReleaseNotesResponse value,
          $Res Function(ReleaseNotesResponse) then) =
      _$ReleaseNotesResponseCopyWithImpl<$Res>;
  $Res call({String notes, String version});
}

/// @nodoc
class _$ReleaseNotesResponseCopyWithImpl<$Res>
    implements $ReleaseNotesResponseCopyWith<$Res> {
  _$ReleaseNotesResponseCopyWithImpl(this._value, this._then);

  final ReleaseNotesResponse _value;
  // ignore: unused_field
  final $Res Function(ReleaseNotesResponse) _then;

  @override
  $Res call({
    Object? notes = freezed,
    Object? version = freezed,
  }) {
    return _then(_value.copyWith(
      notes: notes == freezed
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      version: version == freezed
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
abstract class _$$_ReleaseNotesResponseCopyWith<$Res>
    implements $ReleaseNotesResponseCopyWith<$Res> {
  factory _$$_ReleaseNotesResponseCopyWith(_$_ReleaseNotesResponse value,
          $Res Function(_$_ReleaseNotesResponse) then) =
      __$$_ReleaseNotesResponseCopyWithImpl<$Res>;
  @override
  $Res call({String notes, String version});
}

/// @nodoc
class __$$_ReleaseNotesResponseCopyWithImpl<$Res>
    extends _$ReleaseNotesResponseCopyWithImpl<$Res>
    implements _$$_ReleaseNotesResponseCopyWith<$Res> {
  __$$_ReleaseNotesResponseCopyWithImpl(_$_ReleaseNotesResponse _value,
      $Res Function(_$_ReleaseNotesResponse) _then)
      : super(_value, (v) => _then(v as _$_ReleaseNotesResponse));

  @override
  _$_ReleaseNotesResponse get _value => super._value as _$_ReleaseNotesResponse;

  @override
  $Res call({
    Object? notes = freezed,
    Object? version = freezed,
  }) {
    return _then(_$_ReleaseNotesResponse(
      notes: notes == freezed
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
      version: version == freezed
          ? _value.version
          : version // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_ReleaseNotesResponse implements _ReleaseNotesResponse {
  const _$_ReleaseNotesResponse({required this.notes, required this.version});

  factory _$_ReleaseNotesResponse.fromJson(Map<String, dynamic> json) =>
      _$$_ReleaseNotesResponseFromJson(json);

  @override
  final String notes;
  @override
  final String version;

  @override
  String toString() {
    return 'ReleaseNotesResponse(notes: $notes, version: $version)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_ReleaseNotesResponse &&
            const DeepCollectionEquality().equals(other.notes, notes) &&
            const DeepCollectionEquality().equals(other.version, version));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(notes),
      const DeepCollectionEquality().hash(version));

  @JsonKey(ignore: true)
  @override
  _$$_ReleaseNotesResponseCopyWith<_$_ReleaseNotesResponse> get copyWith =>
      __$$_ReleaseNotesResponseCopyWithImpl<_$_ReleaseNotesResponse>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_ReleaseNotesResponseToJson(
      this,
    );
  }
}

abstract class _ReleaseNotesResponse implements ReleaseNotesResponse {
  const factory _ReleaseNotesResponse(
      {required final String notes,
      required final String version}) = _$_ReleaseNotesResponse;

  factory _ReleaseNotesResponse.fromJson(Map<String, dynamic> json) =
      _$_ReleaseNotesResponse.fromJson;

  @override
  String get notes;
  @override
  String get version;
  @override
  @JsonKey(ignore: true)
  _$$_ReleaseNotesResponseCopyWith<_$_ReleaseNotesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}
