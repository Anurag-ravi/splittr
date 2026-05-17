import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:splittr/features/friends/domain/entities/friend_entity.dart';

part 'friend_model.freezed.dart';
part 'friend_model.g.dart';

@freezed
class FriendModel with _$FriendModel {
  const FriendModel._();

  const factory FriendModel({
    @JsonKey(name: '_id') required String id,
    required String name,
    required String email,
    @JsonKey(name: 'country_code') @Default('') String countryCode,
    @Default('') String phone,
    @Default('cat1') String dp,
  }) = _FriendModel;

  factory FriendModel.fromJson(Map<String, dynamic> json) =>
      _$FriendModelFromJson(json);

  FriendEntity toEntity() => FriendEntity(
        id: id,
        name: name,
        email: email,
        countryCode: countryCode,
        phone: phone,
        dp: dp,
      );
}
