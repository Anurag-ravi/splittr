// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trip_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ShortTripModel _$ShortTripModelFromJson(Map<String, dynamic> json) {
  return _ShortTripModel.fromJson(json);
}

/// @nodoc
mixin _$ShortTripModel {
  @HiveField(1)
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  @HiveField(0)
  String get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ShortTripModelCopyWith<ShortTripModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ShortTripModelCopyWith<$Res> {
  factory $ShortTripModelCopyWith(
          ShortTripModel value, $Res Function(ShortTripModel) then) =
      _$ShortTripModelCopyWithImpl<$Res, ShortTripModel>;
  @useResult
  $Res call(
      {@HiveField(1) @JsonKey(name: '_id') String id,
      @HiveField(0) String name});
}

/// @nodoc
class _$ShortTripModelCopyWithImpl<$Res, $Val extends ShortTripModel>
    implements $ShortTripModelCopyWith<$Res> {
  _$ShortTripModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ShortTripModelImplCopyWith<$Res>
    implements $ShortTripModelCopyWith<$Res> {
  factory _$$ShortTripModelImplCopyWith(_$ShortTripModelImpl value,
          $Res Function(_$ShortTripModelImpl) then) =
      __$$ShortTripModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(1) @JsonKey(name: '_id') String id,
      @HiveField(0) String name});
}

/// @nodoc
class __$$ShortTripModelImplCopyWithImpl<$Res>
    extends _$ShortTripModelCopyWithImpl<$Res, _$ShortTripModelImpl>
    implements _$$ShortTripModelImplCopyWith<$Res> {
  __$$ShortTripModelImplCopyWithImpl(
      _$ShortTripModelImpl _value, $Res Function(_$ShortTripModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
  }) {
    return _then(_$ShortTripModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ShortTripModelImpl extends _ShortTripModel {
  const _$ShortTripModelImpl(
      {@HiveField(1) @JsonKey(name: '_id') required this.id,
      @HiveField(0) required this.name})
      : super._();

  factory _$ShortTripModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ShortTripModelImplFromJson(json);

  @override
  @HiveField(1)
  @JsonKey(name: '_id')
  final String id;
  @override
  @HiveField(0)
  final String name;

  @override
  String toString() {
    return 'ShortTripModel(id: $id, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ShortTripModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ShortTripModelImplCopyWith<_$ShortTripModelImpl> get copyWith =>
      __$$ShortTripModelImplCopyWithImpl<_$ShortTripModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ShortTripModelImplToJson(
      this,
    );
  }
}

abstract class _ShortTripModel extends ShortTripModel {
  const factory _ShortTripModel(
      {@HiveField(1) @JsonKey(name: '_id') required final String id,
      @HiveField(0) required final String name}) = _$ShortTripModelImpl;
  const _ShortTripModel._() : super._();

  factory _ShortTripModel.fromJson(Map<String, dynamic> json) =
      _$ShortTripModelImpl.fromJson;

  @override
  @HiveField(1)
  @JsonKey(name: '_id')
  String get id;
  @override
  @HiveField(0)
  String get name;
  @override
  @JsonKey(ignore: true)
  _$$ShortTripModelImplCopyWith<_$ShortTripModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TripModel _$TripModelFromJson(Map<String, dynamic> json) {
  return _TripModel.fromJson(json);
}

/// @nodoc
mixin _$TripModel {
  @HiveField(0)
  @JsonKey(name: '_id')
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get code => throw _privateConstructorUsedError;
  @HiveField(2)
  String get name => throw _privateConstructorUsedError;
  @HiveField(3)
  DateTime get created => throw _privateConstructorUsedError;
  @HiveField(4)
  String get currency => throw _privateConstructorUsedError;
  @HiveField(5)
  @JsonKey(name: 'created_by')
  String get createdBy => throw _privateConstructorUsedError;
  @HiveField(6)
  List<TripMemberModel> get users => throw _privateConstructorUsedError;
  @HiveField(7)
  List<ExpenseModel> get expenses => throw _privateConstructorUsedError;
  @HiveField(8)
  List<PaymentModel> get payments => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TripModelCopyWith<TripModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TripModelCopyWith<$Res> {
  factory $TripModelCopyWith(TripModel value, $Res Function(TripModel) then) =
      _$TripModelCopyWithImpl<$Res, TripModel>;
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: '_id') String id,
      @HiveField(1) String code,
      @HiveField(2) String name,
      @HiveField(3) DateTime created,
      @HiveField(4) String currency,
      @HiveField(5) @JsonKey(name: 'created_by') String createdBy,
      @HiveField(6) List<TripMemberModel> users,
      @HiveField(7) List<ExpenseModel> expenses,
      @HiveField(8) List<PaymentModel> payments});
}

/// @nodoc
class _$TripModelCopyWithImpl<$Res, $Val extends TripModel>
    implements $TripModelCopyWith<$Res> {
  _$TripModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? created = null,
    Object? currency = null,
    Object? createdBy = null,
    Object? users = null,
    Object? expenses = null,
    Object? payments = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      users: null == users
          ? _value.users
          : users // ignore: cast_nullable_to_non_nullable
              as List<TripMemberModel>,
      expenses: null == expenses
          ? _value.expenses
          : expenses // ignore: cast_nullable_to_non_nullable
              as List<ExpenseModel>,
      payments: null == payments
          ? _value.payments
          : payments // ignore: cast_nullable_to_non_nullable
              as List<PaymentModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TripModelImplCopyWith<$Res>
    implements $TripModelCopyWith<$Res> {
  factory _$$TripModelImplCopyWith(
          _$TripModelImpl value, $Res Function(_$TripModelImpl) then) =
      __$$TripModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) @JsonKey(name: '_id') String id,
      @HiveField(1) String code,
      @HiveField(2) String name,
      @HiveField(3) DateTime created,
      @HiveField(4) String currency,
      @HiveField(5) @JsonKey(name: 'created_by') String createdBy,
      @HiveField(6) List<TripMemberModel> users,
      @HiveField(7) List<ExpenseModel> expenses,
      @HiveField(8) List<PaymentModel> payments});
}

/// @nodoc
class __$$TripModelImplCopyWithImpl<$Res>
    extends _$TripModelCopyWithImpl<$Res, _$TripModelImpl>
    implements _$$TripModelImplCopyWith<$Res> {
  __$$TripModelImplCopyWithImpl(
      _$TripModelImpl _value, $Res Function(_$TripModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? code = null,
    Object? name = null,
    Object? created = null,
    Object? currency = null,
    Object? createdBy = null,
    Object? users = null,
    Object? expenses = null,
    Object? payments = null,
  }) {
    return _then(_$TripModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      created: null == created
          ? _value.created
          : created // ignore: cast_nullable_to_non_nullable
              as DateTime,
      currency: null == currency
          ? _value.currency
          : currency // ignore: cast_nullable_to_non_nullable
              as String,
      createdBy: null == createdBy
          ? _value.createdBy
          : createdBy // ignore: cast_nullable_to_non_nullable
              as String,
      users: null == users
          ? _value._users
          : users // ignore: cast_nullable_to_non_nullable
              as List<TripMemberModel>,
      expenses: null == expenses
          ? _value._expenses
          : expenses // ignore: cast_nullable_to_non_nullable
              as List<ExpenseModel>,
      payments: null == payments
          ? _value._payments
          : payments // ignore: cast_nullable_to_non_nullable
              as List<PaymentModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TripModelImpl extends _TripModel {
  const _$TripModelImpl(
      {@HiveField(0) @JsonKey(name: '_id') required this.id,
      @HiveField(1) required this.code,
      @HiveField(2) required this.name,
      @HiveField(3) required this.created,
      @HiveField(4) required this.currency,
      @HiveField(5) @JsonKey(name: 'created_by') required this.createdBy,
      @HiveField(6) required final List<TripMemberModel> users,
      @HiveField(7) required final List<ExpenseModel> expenses,
      @HiveField(8) required final List<PaymentModel> payments})
      : _users = users,
        _expenses = expenses,
        _payments = payments,
        super._();

  factory _$TripModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TripModelImplFromJson(json);

  @override
  @HiveField(0)
  @JsonKey(name: '_id')
  final String id;
  @override
  @HiveField(1)
  final String code;
  @override
  @HiveField(2)
  final String name;
  @override
  @HiveField(3)
  final DateTime created;
  @override
  @HiveField(4)
  final String currency;
  @override
  @HiveField(5)
  @JsonKey(name: 'created_by')
  final String createdBy;
  final List<TripMemberModel> _users;
  @override
  @HiveField(6)
  List<TripMemberModel> get users {
    if (_users is EqualUnmodifiableListView) return _users;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_users);
  }

  final List<ExpenseModel> _expenses;
  @override
  @HiveField(7)
  List<ExpenseModel> get expenses {
    if (_expenses is EqualUnmodifiableListView) return _expenses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expenses);
  }

  final List<PaymentModel> _payments;
  @override
  @HiveField(8)
  List<PaymentModel> get payments {
    if (_payments is EqualUnmodifiableListView) return _payments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_payments);
  }

  @override
  String toString() {
    return 'TripModel(id: $id, code: $code, name: $name, created: $created, currency: $currency, createdBy: $createdBy, users: $users, expenses: $expenses, payments: $payments)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TripModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.created, created) || other.created == created) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            const DeepCollectionEquality().equals(other._users, _users) &&
            const DeepCollectionEquality().equals(other._expenses, _expenses) &&
            const DeepCollectionEquality().equals(other._payments, _payments));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      code,
      name,
      created,
      currency,
      createdBy,
      const DeepCollectionEquality().hash(_users),
      const DeepCollectionEquality().hash(_expenses),
      const DeepCollectionEquality().hash(_payments));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TripModelImplCopyWith<_$TripModelImpl> get copyWith =>
      __$$TripModelImplCopyWithImpl<_$TripModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TripModelImplToJson(
      this,
    );
  }
}

abstract class _TripModel extends TripModel {
  const factory _TripModel(
          {@HiveField(0) @JsonKey(name: '_id') required final String id,
          @HiveField(1) required final String code,
          @HiveField(2) required final String name,
          @HiveField(3) required final DateTime created,
          @HiveField(4) required final String currency,
          @HiveField(5)
          @JsonKey(name: 'created_by')
          required final String createdBy,
          @HiveField(6) required final List<TripMemberModel> users,
          @HiveField(7) required final List<ExpenseModel> expenses,
          @HiveField(8) required final List<PaymentModel> payments}) =
      _$TripModelImpl;
  const _TripModel._() : super._();

  factory _TripModel.fromJson(Map<String, dynamic> json) =
      _$TripModelImpl.fromJson;

  @override
  @HiveField(0)
  @JsonKey(name: '_id')
  String get id;
  @override
  @HiveField(1)
  String get code;
  @override
  @HiveField(2)
  String get name;
  @override
  @HiveField(3)
  DateTime get created;
  @override
  @HiveField(4)
  String get currency;
  @override
  @HiveField(5)
  @JsonKey(name: 'created_by')
  String get createdBy;
  @override
  @HiveField(6)
  List<TripMemberModel> get users;
  @override
  @HiveField(7)
  List<ExpenseModel> get expenses;
  @override
  @HiveField(8)
  List<PaymentModel> get payments;
  @override
  @JsonKey(ignore: true)
  _$$TripModelImplCopyWith<_$TripModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
