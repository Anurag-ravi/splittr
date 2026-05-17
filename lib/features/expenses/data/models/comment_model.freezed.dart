// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CommentModel {
  @HiveField(0)
  String get id => throw _privateConstructorUsedError;
  @HiveField(1)
  String get entityType => throw _privateConstructorUsedError;
  @HiveField(2)
  String get entityId => throw _privateConstructorUsedError;
  @HiveField(3)
  String get trip => throw _privateConstructorUsedError;
  @HiveField(4)
  String get type => throw _privateConstructorUsedError;
  @HiveField(5)
  String get title => throw _privateConstructorUsedError;
  @HiveField(6)
  String get body => throw _privateConstructorUsedError;
  @HiveField(7)
  DateTime get createdAt => throw _privateConstructorUsedError;
  @HiveField(8)
  String get createdById => throw _privateConstructorUsedError;
  @HiveField(9)
  String get createdByUser => throw _privateConstructorUsedError;
  @HiveField(10)
  String get createdByName => throw _privateConstructorUsedError;
  @HiveField(11)
  String get createdByDp => throw _privateConstructorUsedError;
  @HiveField(12)
  String? get diff => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CommentModelCopyWith<CommentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentModelCopyWith<$Res> {
  factory $CommentModelCopyWith(
          CommentModel value, $Res Function(CommentModel) then) =
      _$CommentModelCopyWithImpl<$Res, CommentModel>;
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String entityType,
      @HiveField(2) String entityId,
      @HiveField(3) String trip,
      @HiveField(4) String type,
      @HiveField(5) String title,
      @HiveField(6) String body,
      @HiveField(7) DateTime createdAt,
      @HiveField(8) String createdById,
      @HiveField(9) String createdByUser,
      @HiveField(10) String createdByName,
      @HiveField(11) String createdByDp,
      @HiveField(12) String? diff});
}

/// @nodoc
class _$CommentModelCopyWithImpl<$Res, $Val extends CommentModel>
    implements $CommentModelCopyWith<$Res> {
  _$CommentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? trip = null,
    Object? type = null,
    Object? title = null,
    Object? body = null,
    Object? createdAt = null,
    Object? createdById = null,
    Object? createdByUser = null,
    Object? createdByName = null,
    Object? createdByDp = null,
    Object? diff = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      trip: null == trip
          ? _value.trip
          : trip // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdById: null == createdById
          ? _value.createdById
          : createdById // ignore: cast_nullable_to_non_nullable
              as String,
      createdByUser: null == createdByUser
          ? _value.createdByUser
          : createdByUser // ignore: cast_nullable_to_non_nullable
              as String,
      createdByName: null == createdByName
          ? _value.createdByName
          : createdByName // ignore: cast_nullable_to_non_nullable
              as String,
      createdByDp: null == createdByDp
          ? _value.createdByDp
          : createdByDp // ignore: cast_nullable_to_non_nullable
              as String,
      diff: freezed == diff
          ? _value.diff
          : diff // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentModelImplCopyWith<$Res>
    implements $CommentModelCopyWith<$Res> {
  factory _$$CommentModelImplCopyWith(
          _$CommentModelImpl value, $Res Function(_$CommentModelImpl) then) =
      __$$CommentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@HiveField(0) String id,
      @HiveField(1) String entityType,
      @HiveField(2) String entityId,
      @HiveField(3) String trip,
      @HiveField(4) String type,
      @HiveField(5) String title,
      @HiveField(6) String body,
      @HiveField(7) DateTime createdAt,
      @HiveField(8) String createdById,
      @HiveField(9) String createdByUser,
      @HiveField(10) String createdByName,
      @HiveField(11) String createdByDp,
      @HiveField(12) String? diff});
}

/// @nodoc
class __$$CommentModelImplCopyWithImpl<$Res>
    extends _$CommentModelCopyWithImpl<$Res, _$CommentModelImpl>
    implements _$$CommentModelImplCopyWith<$Res> {
  __$$CommentModelImplCopyWithImpl(
      _$CommentModelImpl _value, $Res Function(_$CommentModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? entityType = null,
    Object? entityId = null,
    Object? trip = null,
    Object? type = null,
    Object? title = null,
    Object? body = null,
    Object? createdAt = null,
    Object? createdById = null,
    Object? createdByUser = null,
    Object? createdByName = null,
    Object? createdByDp = null,
    Object? diff = freezed,
  }) {
    return _then(_$CommentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      entityType: null == entityType
          ? _value.entityType
          : entityType // ignore: cast_nullable_to_non_nullable
              as String,
      entityId: null == entityId
          ? _value.entityId
          : entityId // ignore: cast_nullable_to_non_nullable
              as String,
      trip: null == trip
          ? _value.trip
          : trip // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      body: null == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdById: null == createdById
          ? _value.createdById
          : createdById // ignore: cast_nullable_to_non_nullable
              as String,
      createdByUser: null == createdByUser
          ? _value.createdByUser
          : createdByUser // ignore: cast_nullable_to_non_nullable
              as String,
      createdByName: null == createdByName
          ? _value.createdByName
          : createdByName // ignore: cast_nullable_to_non_nullable
              as String,
      createdByDp: null == createdByDp
          ? _value.createdByDp
          : createdByDp // ignore: cast_nullable_to_non_nullable
              as String,
      diff: freezed == diff
          ? _value.diff
          : diff // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CommentModelImpl extends _CommentModel {
  const _$CommentModelImpl(
      {@HiveField(0) required this.id,
      @HiveField(1) required this.entityType,
      @HiveField(2) required this.entityId,
      @HiveField(3) required this.trip,
      @HiveField(4) required this.type,
      @HiveField(5) this.title = '',
      @HiveField(6) this.body = '',
      @HiveField(7) required this.createdAt,
      @HiveField(8) required this.createdById,
      @HiveField(9) required this.createdByUser,
      @HiveField(10) required this.createdByName,
      @HiveField(11) required this.createdByDp,
      @HiveField(12) this.diff})
      : super._();

  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String entityType;
  @override
  @HiveField(2)
  final String entityId;
  @override
  @HiveField(3)
  final String trip;
  @override
  @HiveField(4)
  final String type;
  @override
  @JsonKey()
  @HiveField(5)
  final String title;
  @override
  @JsonKey()
  @HiveField(6)
  final String body;
  @override
  @HiveField(7)
  final DateTime createdAt;
  @override
  @HiveField(8)
  final String createdById;
  @override
  @HiveField(9)
  final String createdByUser;
  @override
  @HiveField(10)
  final String createdByName;
  @override
  @HiveField(11)
  final String createdByDp;
  @override
  @HiveField(12)
  final String? diff;

  @override
  String toString() {
    return 'CommentModel(id: $id, entityType: $entityType, entityId: $entityId, trip: $trip, type: $type, title: $title, body: $body, createdAt: $createdAt, createdById: $createdById, createdByUser: $createdByUser, createdByName: $createdByName, createdByDp: $createdByDp, diff: $diff)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.entityType, entityType) ||
                other.entityType == entityType) &&
            (identical(other.entityId, entityId) ||
                other.entityId == entityId) &&
            (identical(other.trip, trip) || other.trip == trip) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.createdById, createdById) ||
                other.createdById == createdById) &&
            (identical(other.createdByUser, createdByUser) ||
                other.createdByUser == createdByUser) &&
            (identical(other.createdByName, createdByName) ||
                other.createdByName == createdByName) &&
            (identical(other.createdByDp, createdByDp) ||
                other.createdByDp == createdByDp) &&
            (identical(other.diff, diff) || other.diff == diff));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      entityType,
      entityId,
      trip,
      type,
      title,
      body,
      createdAt,
      createdById,
      createdByUser,
      createdByName,
      createdByDp,
      diff);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentModelImplCopyWith<_$CommentModelImpl> get copyWith =>
      __$$CommentModelImplCopyWithImpl<_$CommentModelImpl>(this, _$identity);
}

abstract class _CommentModel extends CommentModel {
  const factory _CommentModel(
      {@HiveField(0) required final String id,
      @HiveField(1) required final String entityType,
      @HiveField(2) required final String entityId,
      @HiveField(3) required final String trip,
      @HiveField(4) required final String type,
      @HiveField(5) final String title,
      @HiveField(6) final String body,
      @HiveField(7) required final DateTime createdAt,
      @HiveField(8) required final String createdById,
      @HiveField(9) required final String createdByUser,
      @HiveField(10) required final String createdByName,
      @HiveField(11) required final String createdByDp,
      @HiveField(12) final String? diff}) = _$CommentModelImpl;
  const _CommentModel._() : super._();

  @override
  @HiveField(0)
  String get id;
  @override
  @HiveField(1)
  String get entityType;
  @override
  @HiveField(2)
  String get entityId;
  @override
  @HiveField(3)
  String get trip;
  @override
  @HiveField(4)
  String get type;
  @override
  @HiveField(5)
  String get title;
  @override
  @HiveField(6)
  String get body;
  @override
  @HiveField(7)
  DateTime get createdAt;
  @override
  @HiveField(8)
  String get createdById;
  @override
  @HiveField(9)
  String get createdByUser;
  @override
  @HiveField(10)
  String get createdByName;
  @override
  @HiveField(11)
  String get createdByDp;
  @override
  @HiveField(12)
  String? get diff;
  @override
  @JsonKey(ignore: true)
  _$$CommentModelImplCopyWith<_$CommentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
