import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:splittr/features/activity/domain/entities/activity_entity.dart';

part 'activity_model.freezed.dart';
part 'activity_model.g.dart';

@freezed
class ActivityModel with _$ActivityModel {
  const ActivityModel._();

  const factory ActivityModel({
    required String id,
    @JsonKey(name: 'entity_id') required String entityId,
    @JsonKey(name: 'entity_type') required String entityType,
    required String title,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @Default(false) bool read,
    String? category,
    String? net,
    String? subtitle,
  }) = _ActivityModel;

  factory ActivityModel.fromJson(Map<String, dynamic> json) =>
      _$ActivityModelFromJson(json);

  ActivityEntity toEntity() => ActivityEntity(
        id: id,
        entityId: entityId,
        entityType: entityType,
        title: title,
        createdAt: createdAt,
        read: read,
        category: category,
        net: net,
        subtitle: subtitle,
      );
}
