import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';
import 'package:splittr/features/expenses/domain/entities/expense_entity.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

// Manual fromJson — created_by is a nested object requiring custom extraction.
@HiveType(typeId: 8)
@freezed
class CommentModel with _$CommentModel {
  const CommentModel._();

  const factory CommentModel({
    @HiveField(0) required String id,
    @HiveField(1) required String entityType,
    @HiveField(2) required String entityId,
    @HiveField(3) required String trip,
    @HiveField(4) required String type,
    @HiveField(5) @Default('') String title,
    @HiveField(6) @Default('') String body,
    @HiveField(7) required DateTime createdAt,
    @HiveField(8) required String createdById,
    @HiveField(9) required String createdByUser,
    @HiveField(10) required String createdByName,
    @HiveField(11) required String createdByDp,
    @HiveField(12) String? diff,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final cb = json['created_by'] as Map<String, dynamic>? ?? {};
    return CommentModel(
      id: json['_id'] as String,
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      trip: json['trip'] as String,
      type: json['type'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      createdById: cb['_id'] as String? ?? '',
      createdByUser: cb['user'] as String? ?? '',
      createdByName: cb['name'] as String? ?? '',
      createdByDp: cb['dp'] as String? ?? '',
      diff: json['diff'] != null ? jsonEncode(json['diff']) : null,
    );
  }

  CommentEntity toEntity() => CommentEntity(
        id: id,
        entityType: entityType,
        entityId: entityId,
        tripId: trip,
        type: type,
        title: title,
        body: body,
        createdAt: createdAt,
        createdById: createdById,
        createdByUser: createdByUser,
        createdByName: createdByName,
        createdByDp: createdByDp,
        diff: diff,
      );
}
