// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityModelImpl _$$ActivityModelImplFromJson(Map<String, dynamic> json) =>
    _$ActivityModelImpl(
      id: json['id'] as String,
      entityId: json['entity_id'] as String,
      entityType: json['entity_type'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      read: json['read'] as bool? ?? false,
      category: json['category'] as String?,
      net: json['net'] as String?,
      subtitle: json['subtitle'] as String?,
    );

Map<String, dynamic> _$$ActivityModelImplToJson(_$ActivityModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entity_id': instance.entityId,
      'entity_type': instance.entityType,
      'title': instance.title,
      'created_at': instance.createdAt.toIso8601String(),
      'read': instance.read,
      'category': instance.category,
      'net': instance.net,
      'subtitle': instance.subtitle,
    };
