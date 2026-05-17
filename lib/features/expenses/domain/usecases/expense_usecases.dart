import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/expenses/domain/entities/expense_entity.dart';
import 'package:splittr/features/expenses/domain/entities/split_entry_entity.dart';
import 'package:splittr/features/expenses/domain/repositories/expense_repository.dart';

class SaveExpenseUseCase {
  const SaveExpenseUseCase(this._repo);
  final IExpenseRepository _repo;

  Future<Result<ExpenseEntity>> call({
    required String tripId,
    required String name,
    required double amount,
    required String category,
    required SplitType splitType,
    required List<SplitEntryEntity> paidBy,
    required List<SplitEntryEntity> paidFor,
    required DateTime created,
    String? expenseId,
  }) {
    if (expenseId != null) {
      return _repo.updateExpense(
        expenseId: expenseId, tripId: tripId, name: name,
        amount: amount, category: category, splitType: splitType,
        paidBy: paidBy, paidFor: paidFor, created: created,
      );
    }
    return _repo.createExpense(
      tripId: tripId, name: name, amount: amount, category: category,
      splitType: splitType, paidBy: paidBy, paidFor: paidFor, created: created,
    );
  }
}

class DeleteExpenseUseCase {
  const DeleteExpenseUseCase(this._repo);
  final IExpenseRepository _repo;
  Future<Result<void>> call(String expenseId) => _repo.deleteExpense(expenseId);
}

class FetchExpenseCommentsUseCase {
  const FetchExpenseCommentsUseCase(this._repo);
  final IExpenseRepository _repo;
  Future<Result<List<CommentEntity>>> call(String expenseId) =>
      _repo.fetchComments(expenseId);
}

class PostExpenseCommentUseCase {
  const PostExpenseCommentUseCase(this._repo);
  final IExpenseRepository _repo;
  Future<Result<void>> call({
    required String expenseId,
    required String tripId,
    required String expenseName,
    required String body,
  }) =>
      _repo.postComment(
          expenseId: expenseId, tripId: tripId,
          expenseName: expenseName, body: body);
}

class DeleteExpenseCommentUseCase {
  const DeleteExpenseCommentUseCase(this._repo);
  final IExpenseRepository _repo;
  Future<Result<void>> call(String commentId) => _repo.deleteComment(commentId);
}
