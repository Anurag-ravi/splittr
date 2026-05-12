class ActivityModel {
  final String id;
  final String entityId;
  final String entityType;
  final String? category;
  final String title;
  final String? net;
  final String? subtitle;
  final DateTime createdAt;
  bool read;

  ActivityModel({
    required this.id,
    required this.entityId,
    required this.entityType,
    this.category,
    required this.title,
    this.net,
    this.subtitle,
    required this.createdAt,
    required this.read,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      entityId: json['entity_id'],
      entityType: json['entity_type'],
      category: json['category'],
      title: json['title'],
      net: json['net'],
      subtitle: json['subtitle'],
      createdAt: DateTime.parse(json['created_at']),
      read: json['read'] ?? false,
    );
  }
}
