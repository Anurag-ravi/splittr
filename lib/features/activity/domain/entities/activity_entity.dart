import 'package:equatable/equatable.dart';

class ActivityEntity extends Equatable {
  const ActivityEntity({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.title,
    required this.createdAt,
    required this.read,
    this.category,
    this.net,
    this.subtitle,
  });

  final String id;
  final String entityId;
  final String entityType;
  final String title;
  final DateTime createdAt;
  final bool read;
  final String? category;
  final String? net;
  final String? subtitle;

  ActivityEntity copyWith({bool? read}) => ActivityEntity(
        id: id,
        entityId: entityId,
        entityType: entityType,
        title: title,
        createdAt: createdAt,
        read: read ?? this.read,
        category: category,
        net: net,
        subtitle: subtitle,
      );

  @override
  List<Object?> get props => [id, entityId, entityType, createdAt, read];
}
