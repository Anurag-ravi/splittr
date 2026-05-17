// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TripMemberModel _$TripMemberModelFromJson(Map<String, dynamic> json) {
  return _TripMemberModel.fromJson(json);
}

/// @nodoc
mixin _$TripMemberModel {
  @HiveField(0)
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get trip => throw _privateConstructorUsedError;
  @HiveField(2)
  String get user => throw _privateConstructorUsedError;
  @HiveField(3)
  String get name => throw _privateConstructorUsedError;
  @HiveField(4)
  String get dp => throw _privateConstructorUsedError;
  @HiveField(5)
  bool get involved => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TripMemberModelCopyWith<TripMemberModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripMemberModelCopyWith<$Res> {
  factory $TripMemberModelCopyWith(
          TripMemberModel value, $Res Function(TripMemberModel) then) =
      _$TripMemberModelCopyWithImpl<$Res, TripMemberModel>;
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: '_id') String id,
      @HiveField(1) String trip,
      @HiveField(2) String user,
      @HiveField(3) String name,
      @HiveField(4) String dp,
      @HiveField(5) bool involved});
}

/// @nodoc
class _$TripMemberModelCopyWithImpl<$Res, $Val extends TripMemberModel>
    implements $TripMemberModelCopyWith<$Res> {
  _$TripMemberModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trip = null,
    Object? user = null,
    Object? name = null,
    Object? dp = null,
    Object? involved = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      trip: null == trip
          ? _value.trip
          : trip // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dp: null == dp
          ? _value.dp
          : dp // ignore: cast_nullable_to_non_nullable
              as String,
      involved: null == involved
          ? _value.involved
          : involved // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripMemberModelImplCopyWith<$Res>
    implements $TripMemberModelCopyWith<$Res> {
  factory _$$TripMemberModelImplCopyWith(_$TripMemberModelImpl value,
          $Res Function(_$TripMemberModelImpl) then) =
      __$$TripMemberModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: '_id') String id,
      @HiveField(1) String trip,
      @HiveField(2) String user,
      @HiveField(3) String name,
      @HiveField(4) String dp,
      @HiveField(5) bool involved});
}

/// @nodoc
class __$$TripMemberModelImplCopyWithImpl<$Res>
    extends _$TripMemberModelCopyWithImpl<$Res, _$TripMemberModelImpl>
    implements _$$TripMemberModelImplCopyWith<$Res> {
  __$$TripMemberModelImplCopyWithImpl(
      _$TripMemberModelImpl _value, $Res Function(_$TripMemberModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trip = null,
    Object? user = null,
    Object? name = null,
    Object? dp = null,
    Object? involved = null,
  }) {
    return _then(_$TripMemberModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      trip: null == trip
          ? _value.trip
          : trip // ignore: cast_nullable_to_non_nullable
              as String,
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      dp: null == dp
          ? _value.dp
          : dp // ignore: cast_nullable_to_non_nullable
              as String,
      involved: null == involved
          ? _value.involved
          : involved // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripMemberModelImpl extends _TripMemberModel {
  const _$TripMemberModelImpl(
      {@HiveField(0) @JsonKey(name: '_id') required this.id,
      @HiveField(1) required this.trip,
      @HiveField(2) required this.user,
      @HiveField(3) required this.name,
      @HiveField(4) required this.dp,
      @HiveField(5) required this.involved})
      : super._();

  factory _$TripMemberModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripMemberModelImplFromJson(json);

  @override
  @HiveField(0)
  @JsonKey(name: '_id')
  final String id;
  @override
  @HiveField(1)
  final String trip;
  @override
  @HiveField(2)
  final String user;
  @override
  @HiveField(3)
  final String name;
  @override
  @HiveField(4)
  final String dp;
  @override
  @HiveField(5)
  final bool involved;

  @override
  String toString() {
    return 'TripMemberModel(id: $id, trip: $trip, user: $user, name: $name, dp: $dp, involved: $involved)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripMemberModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trip, trip) || other.trip == trip) &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dp, dp) || other.dp == dp) &&
            (identical(other.involved, involved) ||
                other.involved == involved));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, trip, user, name, dp, involved);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TripMemberModelImplCopyWith<_$TripMemberModelImpl> get copyWith =>
      __$$TripMemberModelImplCopyWithImpl<_$TripMemberModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripMemberModelImplToJson(
      this,
    );
  }
}

abstract class _TripMemberModel extends TripMemberModel {
  const factory _TripMemberModel(
      {@HiveField(0) @JsonKey(name: '_id') required final String id,
      @HiveField(1) required final String trip,
      @HiveField(2) required final String user,
      @HiveField(3) required final String name,
      @HiveField(4) required final String dp,
      @HiveField(5) required final bool involved}) = _$TripMemberModelImpl;
  const _TripMemberModel._() : super._();

  factory _TripMemberModel.fromJson(Map<String, dynamic> json) =
      _$TripMemberModelImpl.fromJson;

  @override
  @HiveField(0)
  @JsonKey(name: '_id')
  String get id;
  @override
  @HiveField(1)
  String get trip;
  @override
  @HiveField(2)
  String get user;
  @override
  @HiveField(3)
  String get name;
  @override
  @HiveField(4)
  String get dp;
  @override
  @HiveField(5)
  bool get involved;
  @override
  @JsonKey(ignore: true)
  _$$TripMemberModelImplCopyWith<_$TripMemberModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
