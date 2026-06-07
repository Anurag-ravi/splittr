import 'package:equatable/equatable.dart';
import 'package:splittr/features/expenses/domain/entities/split_entry_entity.dart';

enum SplitType { equal, unequal, shares, percent }

class ExpenseEntity extends Equatable {
  const ExpenseEntity({
    required this.id,
    required this.tripId,
    required this.name,
    required this.amount,
    required this.category,
    required this.splitType,
    required this.created,
    required this.paidBy,
    required this.paidFor,
    this.comments = const [],
  });

  final String id;
  final String tripId;
  final String name;
  final double amount;
  final String category;
  final SplitType splitType;
  final DateTime created;
  final List<SplitEntryEntity> paidBy;
  final List<SplitEntryEntity> paidFor;
  final List<CommentEntity> comments;

  ExpenseEntity copyWith({
    String? id,
    String? tripId,
    String? name,
    double? amount,
    String? category,
    SplitType? splitType,
    DateTime? created,
    List<SplitEntryEntity>? paidBy,
    List<SplitEntryEntity>? paidFor,
    List<CommentEntity>? comments,
  }) =>
      ExpenseEntity(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        splitType: splitType ?? this.splitType,
        created: created ?? this.created,
        paidBy: paidBy ?? this.paidBy,
        paidFor: paidFor ?? this.paidFor,
        comments: comments ?? this.comments,
      );

  @override
  List<Object?> get props =>
      [id, tripId, name, amount, category, splitType, created, paidBy, paidFor];
}

/// Thin domain entity for a comment (shared by expenses and payments).
class CommentEntity extends Equatable {
  const CommentEntity({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.tripId,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.createdById,
    required this.createdByUser,
    required this.createdByName,
    required this.createdByDp,
    this.diff,
  });

  final String id;
  final String entityType;
  final String entityId;
  final String tripId;
  final String type;
  final String title;
  final String body;
  final DateTime createdAt;
  final String createdById;
  final String createdByUser;
  final String createdByName;
  final String createdByDp;
  final String? diff;

  @override
  List<Object?> get props => [id, entityType, entityId, createdAt];
}
