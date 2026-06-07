// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExpenseModel _$ExpenseModelFromJson(Map<String, dynamic> json) {
  return _ExpenseModel.fromJson(json);
}

/// @nodoc
mixin _$ExpenseModel {
  @HiveField(0)
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get trip => throw _privateConstructorUsedError;
  @HiveField(2)
  String get name => throw _privateConstructorUsedError;
  @HiveField(3)
  double get amount => throw _privateConstructorUsedError;
  @HiveField(4)
  String get category => throw _privateConstructorUsedError;
  @HiveField(5)
  @JsonKey(name: 'split_type')
  String get splitType => throw _privateConstructorUsedError;
  @HiveField(6)
  DateTime get created => throw _privateConstructorUsedError;
  @HiveField(7)
  @JsonKey(name: 'paid_by')
  List<SplitEntryModel> get paidBy => throw _privateConstructorUsedError;
  @HiveField(8)
  @JsonKey(name: 'paid_for')
  List<SplitEntryModel> get paidFor => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExpenseModelCopyWith<ExpenseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseModelCopyWith<$Res> {
  factory $ExpenseModelCopyWith(
          ExpenseModel value, $Res Function(ExpenseModel) then) =
      _$ExpenseModelCopyWithImpl<$Res, ExpenseModel>;
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: '_id') String id,
      @HiveField(1) String trip,
      @HiveField(2) String name,
      @HiveField(3) double amount,
      @HiveField(4) String category,
      @HiveField(5) @JsonKey(name: 'split_type') String splitType,
      @HiveField(6) DateTime created,
      @HiveField(7) @JsonKey(name: 'paid_by') List<SplitEntryModel> paidBy,
      @HiveField(8) @JsonKey(name: 'paid_for') List<SplitEntryModel> paidFor});
}

/// @nodoc
class _$ExpenseModelCopyWithImpl<$Res, $Val extends ExpenseModel>
    implements $ExpenseModelCopyWith<$Res> {
  _$ExpenseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trip = null,
    Object? name = null,
    Object? amount = null,
    Object? category = null,
    Object? splitType = null,
    Object? created = null,
    Object? paidBy = null,
    Object? paidFor = null,
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
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      splitType: null == splitType
          ? _value.splitType
          : splitType // ignore: cast_nullable_to_non_nullable
              as String,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
      paidBy: null == paidBy
          ? _value.paidBy
          : paidBy // ignore: cast_nullable_to_non_nullable
              as List<SplitEntryModel>,
      paidFor: null == paidFor
          ? _value.paidFor
          : paidFor // ignore: cast_nullable_to_non_nullable
              as List<SplitEntryModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpenseModelImplCopyWith<$Res>
    implements $ExpenseModelCopyWith<$Res> {
  factory _$$ExpenseModelImplCopyWith(
          _$ExpenseModelImpl value, $Res Function(_$ExpenseModelImpl) then) =
      __$$ExpenseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: '_id') String id,
      @HiveField(1) String trip,
      @HiveField(2) String name,
      @HiveField(3) double amount,
      @HiveField(4) String category,
      @HiveField(5) @JsonKey(name: 'split_type') String splitType,
      @HiveField(6) DateTime created,
      @HiveField(7) @JsonKey(name: 'paid_by') List<SplitEntryModel> paidBy,
      @HiveField(8) @JsonKey(name: 'paid_for') List<SplitEntryModel> paidFor});
}

/// @nodoc
class __$$ExpenseModelImplCopyWithImpl<$Res>
    extends _$ExpenseModelCopyWithImpl<$Res, _$ExpenseModelImpl>
    implements _$$ExpenseModelImplCopyWith<$Res> {
  __$$ExpenseModelImplCopyWithImpl(
      _$ExpenseModelImpl _value, $Res Function(_$ExpenseModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? trip = null,
    Object? name = null,
    Object? amount = null,
    Object? category = null,
    Object? splitType = null,
    Object? created = null,
    Object? paidBy = null,
    Object? paidFor = null,
  }) {
    return _then(_$ExpenseModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      trip: null == trip
          ? _value.trip
          : trip // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as double,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      splitType: null == splitType
          ? _value.splitType
          : splitType // ignore: cast_nullable_to_non_nullable
              as String,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
      paidBy: null == paidBy
          ? _value._paidBy
          : paidBy // ignore: cast_nullable_to_non_nullable
              as List<SplitEntryModel>,
      paidFor: null == paidFor
          ? _value._paidFor
          : paidFor // ignore: cast_nullable_to_non_nullable
              as List<SplitEntryModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExpenseModelImpl extends _ExpenseModel {
  const _$ExpenseModelImpl(
      {@HiveField(0) @JsonKey(name: '_id') required this.id,
      @HiveField(1) required this.trip,
      @HiveField(2) required this.name,
      @HiveField(3) required this.amount,
      @HiveField(4) required this.category,
      @HiveField(5) @JsonKey(name: 'split_type') required this.splitType,
      @HiveField(6) required this.created,
      @HiveField(7)
      @JsonKey(name: 'paid_by')
      required final List<SplitEntryModel> paidBy,
      @HiveField(8)
      @JsonKey(name: 'paid_for')
      required final List<SplitEntryModel> paidFor})
      : _paidBy = paidBy,
        _paidFor = paidFor,
        super._();

  factory _$ExpenseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExpenseModelImplFromJson(json);

  @override
  @HiveField(0)
  @JsonKey(name: '_id')
  final String id;
  @override
  @HiveField(1)
  final String trip;
  @override
  @HiveField(2)
  final String name;
  @override
  @HiveField(3)
  final double amount;
  @override
  @HiveField(4)
  final String category;
  @override
  @HiveField(5)
  @JsonKey(name: 'split_type')
  final String splitType;
  @override
  @HiveField(6)
  final DateTime created;
  final List<SplitEntryModel> _paidBy;
  @override
  @HiveField(7)
  @JsonKey(name: 'paid_by')
  List<SplitEntryModel> get paidBy {
    if (_paidBy is EqualUnmodifiableListView) return _paidBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paidBy);
  }

  final List<SplitEntryModel> _paidFor;
  @override
  @HiveField(8)
  @JsonKey(name: 'paid_for')
  List<SplitEntryModel> get paidFor {
    if (_paidFor is EqualUnmodifiableListView) return _paidFor;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_paidFor);
  }

  @override
  String toString() {
    return 'ExpenseModel(id: $id, trip: $trip, name: $name, amount: $amount, category: $category, splitType: $splitType, created: $created, paidBy: $paidBy, paidFor: $paidFor)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.trip, trip) || other.trip == trip) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.splitType, splitType) ||
                other.splitType == splitType) &&
            (identical(other.created, created) || other.created == created) &&
            const DeepCollectionEquality().equals(other._paidBy, _paidBy) &&
            const DeepCollectionEquality().equals(other._paidFor, _paidFor));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      trip,
      name,
      amount,
      category,
      splitType,
      created,
      const DeepCollectionEquality().hash(_paidBy),
      const DeepCollectionEquality().hash(_paidFor));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseModelImplCopyWith<_$ExpenseModelImpl> get copyWith =>
      __$$ExpenseModelImplCopyWithImpl<_$ExpenseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExpenseModelImplToJson(
      this,
    );
  }
}

abstract class _ExpenseModel extends ExpenseModel {
  const factory _ExpenseModel(
      {@HiveField(0) @JsonKey(name: '_id') required final String id,
      @HiveField(1) required final String trip,
      @HiveField(2) required final String name,
      @HiveField(3) required final double amount,
      @HiveField(4) required final String category,
      @HiveField(5)
      @JsonKey(name: 'split_type')
      required final String splitType,
      @HiveField(6) required final DateTime created,
      @HiveField(7)
      @JsonKey(name: 'paid_by')
      required final List<SplitEntryModel> paidBy,
      @HiveField(8)
      @JsonKey(name: 'paid_for')
      required final List<SplitEntryModel> paidFor}) = _$ExpenseModelImpl;
  const _ExpenseModel._() : super._();

  factory _ExpenseModel.fromJson(Map<String, dynamic> json) =
      _$ExpenseModelImpl.fromJson;

  @override
  @HiveField(0)
  @JsonKey(name: '_id')
  String get id;
  @override
  @HiveField(1)
  String get trip;
  @override
  @HiveField(2)
  String get name;
  @override
  @HiveField(3)
  double get amount;
  @override
  @HiveField(4)
  String get category;
  @override
  @HiveField(5)
  @JsonKey(name: 'split_type')
  String get splitType;
  @override
  @HiveField(6)
  DateTime get created;
  @override
  @HiveField(7)
  @JsonKey(name: 'paid_by')
  List<SplitEntryModel> get paidBy;
  @override
  @HiveField(8)
  @JsonKey(name: 'paid_for')
  List<SplitEntryModel> get paidFor;
  @override
  @JsonKey(ignore: true)
  _$$ExpenseModelImplCopyWith<_$ExpenseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
