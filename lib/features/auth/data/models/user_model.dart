import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:splittr/features/auth/domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@HiveType(typeId: 0)
@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    @HiveField(0) @JsonKey(name: '_id') required String id,
    @HiveField(1) required String name,
    @HiveField(2) required String email,
    @HiveField(3) @JsonKey(name: 'country_code') required String countryCode,
    @HiveField(4) required String phone,
    @HiveField(5) @JsonKey(name: 'upi_id') required String upiId,
    @HiveField(6) required String dp,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserEntity toEntity() => UserEntity(
        id: id,
        name: name,
        email: email,
        countryCode: countryCode,
        phone: phone,
        upiId: upiId,
        dp: dp,
      );

  static UserModel fromEntity(UserEntity e) => UserModel(
        id: e.id,
        name: e.name,
        email: e.email,
        countryCode: e.countryCode,
        phone: e.phone,
        upiId: e.upiId,
        dp: e.dp,
      );
}
