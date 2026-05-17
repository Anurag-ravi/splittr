import 'package:equatable/equatable.dart';
import 'package:splittr/features/expenses/domain/entities/expense_entity.dart';

class PaymentEntity extends Equatable {
  const PaymentEntity({
    required this.id,
    required this.tripId,
    required this.amount,
    required this.created,
    required this.byMemberId,
    required this.toMemberId,
    this.comments = const [],
  });

  final String id;
  final String tripId;
  final double amount;
  final DateTime created;
  final String byMemberId;
  final String toMemberId;
  final List<CommentEntity> comments;

  PaymentEntity copyWith({
    String? id,
    String? tripId,
    double? amount,
    DateTime? created,
    String? byMemberId,
    String? toMemberId,
    List<CommentEntity>? comments,
  }) =>
      PaymentEntity(
        id: id ?? this.id,
        tripId: tripId ?? this.tripId,
        amount: amount ?? this.amount,
        created: created ?? this.created,
        byMemberId: byMemberId ?? this.byMemberId,
        toMemberId: toMemberId ?? this.toMemberId,
        comments: comments ?? this.comments,
      );

  @override
  List<Object?> get props =>
      [id, tripId, amount, created, byMemberId, toMemberId];
}
