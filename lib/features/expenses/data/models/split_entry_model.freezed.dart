// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'split_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SplitEntryModel _$SplitEntryModelFromJson(Map<String, dynamic> json) {
  return _SplitEntryModel.fromJson(json);
}

/// @nodoc
mixin _$SplitEntryModel {
  @HiveField(0)
  String get user => throw _privateConstructorUsedError;
  @HiveField(1)
  double get amount => throw _privateConstructorUsedError;
  @HiveField(2)
  @JsonKey(name: 'share_or_percent')
  double get shareOrPercent => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $SplitEntryModelCopyWith<SplitEntryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SplitEntryModelCopyWith<$Res> {
  factory $SplitEntryModelCopyWith(
          SplitEntryModel value, $Res Function(SplitEntryModel) then) =
      _$SplitEntryModelCopyWithImpl<$Res, SplitEntryModel>;
  @useResult
  $Res call(
      {@HiveField(0) String user,
      @HiveField(1) double amount,
      @HiveField(2) @JsonKey(name: 'share_or_percent') double shareOrPercent});
}

/// @nodoc
class _$SplitEntryModelCopyWithImpl<$Res, $Val extends SplitEntryModel>
    implements $SplitEntryModelCopyWith<$Res> {
  _$SplitEntryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? amount = null,
    Object? shareOrPercent = null,
  }) {
    return _then(_value.copyWith(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      shareOrPercent: null == shareOrPercent
          ? _value.shareOrPercent
          : shareOrPercent // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SplitEntryModelImplCopyWith<$Res>
    implements $SplitEntryModelCopyWith<$Res> {
  factory _$$SplitEntryModelImplCopyWith(_$SplitEntryModelImpl value,
          $Res Function(_$SplitEntryModelImpl) then) =
      __$$SplitEntryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String user,
      @HiveField(1) double amount,
      @HiveField(2) @JsonKey(name: 'share_or_percent') double shareOrPercent});
}

/// @nodoc
class __$$SplitEntryModelImplCopyWithImpl<$Res>
    extends _$SplitEntryModelCopyWithImpl<$Res, _$SplitEntryModelImpl>
    implements _$$SplitEntryModelImplCopyWith<$Res> {
  __$$SplitEntryModelImplCopyWithImpl(
      _$SplitEntryModelImpl _value, $Res Function(_$SplitEntryModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = null,
    Object? amount = null,
    Object? shareOrPercent = null,
  }) {
    return _then(_$SplitEntryModelImpl(
      user: null == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      shareOrPercent: null == shareOrPercent
          ? _value.shareOrPercent
          : shareOrPercent // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SplitEntryModelImpl extends _SplitEntryModel {
  const _$SplitEntryModelImpl(
      {@HiveField(0) required this.user,
      @HiveField(1) required this.amount,
      @HiveField(2)
      @JsonKey(name: 'share_or_percent')
      this.shareOrPercent = 0.0})
      : super._();

  factory _$SplitEntryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SplitEntryModelImplFromJson(json);

  @override
  @HiveField(0)
  final String user;
  @override
  @HiveField(1)
  final double amount;
  @override
  @HiveField(2)
  @JsonKey(name: 'share_or_percent')
  final double shareOrPercent;

  @override
  String toString() {
    return 'SplitEntryModel(user: $user, amount: $amount, shareOrPercent: $shareOrPercent)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SplitEntryModelImpl &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.shareOrPercent, shareOrPercent) ||
                other.shareOrPercent == shareOrPercent));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, user, amount, shareOrPercent);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SplitEntryModelImplCopyWith<_$SplitEntryModelImpl> get copyWith =>
      __$$SplitEntryModelImplCopyWithImpl<_$SplitEntryModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SplitEntryModelImplToJson(
      this,
    );
  }
}

abstract class _SplitEntryModel extends SplitEntryModel {
  const factory _SplitEntryModel(
      {@HiveField(0) required final String user,
      @HiveField(1) required final double amount,
      @HiveField(2)
      @JsonKey(name: 'share_or_percent')
      final double shareOrPercent}) = _$SplitEntryModelImpl;
  const _SplitEntryModel._() : super._();

  factory _SplitEntryModel.fromJson(Map<String, dynamic> json) =
      _$SplitEntryModelImpl.fromJson;

  @override
  @HiveField(0)
  String get user;
  @override
  @HiveField(1)
  double get amount;
  @override
  @HiveField(2)
  @JsonKey(name: 'share_or_percent')
  double get shareOrPercent;
  @override
  @JsonKey(ignore: true)
  _$$SplitEntryModelImplCopyWith<_$SplitEntryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
