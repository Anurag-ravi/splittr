import 'package:equatable/equatable.dart';
import 'package:splittr/features/expenses/domain/entities/expense_entity.dart';
import 'package:splittr/features/payments/domain/entities/payment_entity.dart';
import 'package:splittr/features/trips/domain/entities/trip_member_entity.dart';

class ShortTripEntity extends Equatable {
  const ShortTripEntity({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}

class TripEntity extends Equatable {
  const TripEntity({
    required this.id,
    required this.code,
    required this.name,
    required this.created,
    required this.currency,
    required this.createdBy,
    required this.members,
    required this.expenses,
    required this.payments,
  });

  final String id;
  final String code;
  final String name;
  final DateTime created;
  final String currency;
  final String createdBy;
  final List<TripMemberEntity> members;
  final List<ExpenseEntity> expenses;
  final List<PaymentEntity> payments;

  TripEntity copyWith({
    String? id,
    String? code,
    String? name,
    DateTime? created,
    String? currency,
    String? createdBy,
    List<TripMemberEntity>? members,
    List<ExpenseEntity>? expenses,
    List<PaymentEntity>? payments,
  }) =>
      TripEntity(
        id: id ?? this.id,
        code: code ?? this.code,
        name: name ?? this.name,
        created: created ?? this.created,
        currency: currency ?? this.currency,
        createdBy: createdBy ?? this.createdBy,
        members: members ?? this.members,
        expenses: expenses ?? this.expenses,
        payments: payments ?? this.payments,
      );

  @override
  List<Object?> get props =>
      [id, code, name, created, currency, createdBy, members, expenses, payments];
}
