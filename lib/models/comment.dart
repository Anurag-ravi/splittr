import 'dart:convert';

import 'package:hive/hive.dart';

part 'comment.g.dart';

@HiveType(typeId: 8)
class CommentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String entity_type;

  @HiveField(2)
  String entity_id;

  @HiveField(3)
  String trip;

  @HiveField(4)
  String type;

  @HiveField(5)
  String title;

  @HiveField(6)
  String body_text;

  @HiveField(7)
  DateTime created_at;

  @HiveField(8)
  String created_by_id;

  @HiveField(9)
  String created_by_user;

  @HiveField(10)
  String created_by_name;

  @HiveField(11)
  String created_by_dp;

  // Raw JSON string of {before: {...}, after: {...}}. Null for user comments.
  @HiveField(12)
  String? diff;

  CommentModel(
    this.id,
    this.entity_type,
    this.entity_id,
    this.trip,
    this.type,
    this.title,
    this.body_text,
    this.created_at,
    this.created_by_id,
    this.created_by_user,
    this.created_by_name,
    this.created_by_dp, {
    this.diff,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    final cb = json['created_by'];
    return CommentModel(
      json['_id'],
      json['entity_type'],
      json['entity_id'],
      json['trip'],
      json['type'],
      json['title'] ?? '',
      json['body'] ?? '',
      DateTime.parse(json['created_at']).toLocal(),
      cb['_id'],
      cb['user'],
      cb['name'],
      cb['dp'],
      diff: json['diff'] != null ? jsonEncode(json['diff']) : null,
    );
  }
}
