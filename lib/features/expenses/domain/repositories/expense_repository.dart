import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/expenses/domain/entities/expense_entity.dart';
import 'package:splittr/features/expenses/domain/entities/split_entry_entity.dart';

abstract interface class IExpenseRepository {
  Future<Result<ExpenseEntity>> createExpense({
    required String tripId,
    required String name,
    required double amount,
    required String category,
    required SplitType splitType,
    required List<SplitEntryEntity> paidBy,
    required List<SplitEntryEntity> paidFor,
    required DateTime created,
  });

  Future<Result<ExpenseEntity>> updateExpense({
    required String expenseId,
    required String tripId,
    required String name,
    required double amount,
    required String category,
    required SplitType splitType,
    required List<SplitEntryEntity> paidBy,
    required List<SplitEntryEntity> paidFor,
    required DateTime created,
  });

  Future<Result<void>> deleteExpense(String expenseId);

  Future<Result<List<CommentEntity>>> fetchComments(String expenseId);
  Future<Result<void>> postComment({
    required String expenseId,
    required String tripId,
    required String expenseName,
    required String body,
  });
  Future<Result<void>> deleteComment(String commentId);
}
