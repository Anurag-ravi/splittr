// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friend_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FriendModelImpl _$$FriendModelImplFromJson(Map<String, dynamic> json) =>
    _$FriendModelImpl(
      id: json['_id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      countryCode: json['country_code'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      dp: json['dp'] as String? ?? 'cat1',
    );

Map<String, dynamic> _$$FriendModelImplToJson(_$FriendModelImpl instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'email': instance.email,
      'country_code': instance.countryCode,
      'phone': instance.phone,
      'dp': instance.dp,
    };
