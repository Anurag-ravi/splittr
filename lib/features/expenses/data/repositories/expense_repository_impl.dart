import 'package:splittr/core/errors/exceptions.dart';
import 'package:splittr/core/errors/failures.dart';
import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/expenses/data/datasources/expense_remote_datasource.dart';
import 'package:splittr/features/expenses/data/models/split_entry_model.dart';
import 'package:splittr/features/expenses/domain/entities/expense_entity.dart';
import 'package:splittr/features/expenses/domain/entities/split_entry_entity.dart';
import 'package:splittr/features/expenses/domain/repositories/expense_repository.dart';

class ExpenseRepositoryImpl implements IExpenseRepository {
  const ExpenseRepositoryImpl(this._remote);
  final IExpenseRemoteDatasource _remote;

  @override
  Future<Result<ExpenseEntity>> createExpense({
    required String tripId,
    required String name,
    required double amount,
    required String category,
    required SplitType splitType,
    required List<SplitEntryEntity> paidBy,
    required List<SplitEntryEntity> paidFor,
    required DateTime created,
  }) async {
    try {
      final model = await _remote.createExpense(
        tripId: tripId,
        name: name,
        amount: amount,
        category: category,
        splitType: splitType.name,
        paidBy: paidBy.map(SplitEntryModel.fromEntity).toList(),
        paidFor: paidFor.map(SplitEntryModel.fromEntity).toList(),
        created: '${created.toIso8601String()}',
      );
      return ok(model.toEntity());
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
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
  }) async {
    try {
      final model = await _remote.updateExpense(
        expenseId: expenseId,
        tripId: tripId,
        name: name,
        amount: amount,
        category: category,
        splitType: splitType.name,
        paidBy: paidBy.map(SplitEntryModel.fromEntity).toList(),
        paidFor: paidFor.map(SplitEntryModel.fromEntity).toList(),
        created: '${created.toIso8601String()}',
      );
      return ok(model.toEntity());
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteExpense(String expenseId) async {
    try {
      await _remote.deleteExpense(expenseId);
      return ok(null);
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<CommentEntity>>> fetchComments(String expenseId) async {
    try {
      final models = await _remote.fetchComments(expenseId);
      return ok(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> postComment({
    required String expenseId,
    required String tripId,
    required String expenseName,
    required String body,
  }) async {
    try {
      await _remote.postComment(
        expenseId: expenseId,
        tripId: tripId,
        title: 'Comment added on expense "$expenseName"',
        body: body,
      );
      return ok(null);
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    try {
      await _remote.deleteComment(commentId);
      return ok(null);
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }
}
