import 'package:splittr/core/errors/exceptions.dart';
import 'package:splittr/core/network/api_client.dart';
import 'package:splittr/features/expenses/data/models/comment_model.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/expenses/data/models/split_entry_model.dart';

abstract interface class IExpenseRemoteDatasource {
  Future<ExpenseModel> createExpense({
    required String tripId, required String name, required double amount,
    required String category, required String splitType,
    required List<SplitEntryModel> paidBy, required List<SplitEntryModel> paidFor,
    required String created,
  });
  Future<ExpenseModel> updateExpense({
    required String expenseId, required String tripId, required String name,
    required double amount, required String category, required String splitType,
    required List<SplitEntryModel> paidBy, required List<SplitEntryModel> paidFor,
    required String created,
  });
  Future<void> deleteExpense(String expenseId);
  Future<List<CommentModel>> fetchComments(String expenseId);
  Future<void> postComment({
    required String expenseId, required String tripId,
    required String title, required String body,
  });
  Future<void> deleteComment(String commentId);
}

class ExpenseRemoteDatasource implements IExpenseRemoteDatasource {
  const ExpenseRemoteDatasource(this._client);
  final ApiClient _client;

  @override
  Future<ExpenseModel> createExpense({
    required String tripId, required String name, required double amount,
    required String category, required String splitType,
    required List<SplitEntryModel> paidBy, required List<SplitEntryModel> paidFor,
    required String created,
  }) async {
    final data = await _client.post('/expense/new', {
      'id': '', 'trip': tripId, 'name': name, 'amount': amount,
      'category': category, 'split_type': splitType,
      'paid_by': paidBy.map((b) => b.toJson()).toList(),
      'paid_for': paidFor.map((b) => b.toJson()).toList(),
      'created': created,
    });
    _check(data);
    return ExpenseModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<ExpenseModel> updateExpense({
    required String expenseId, required String tripId, required String name,
    required double amount, required String category, required String splitType,
    required List<SplitEntryModel> paidBy, required List<SplitEntryModel> paidFor,
    required String created,
  }) async {
    final data = await _client.post('/expense/update', {
      'id': expenseId, 'trip': tripId, 'name': name, 'amount': amount,
      'category': category, 'split_type': splitType,
      'paid_by': paidBy.map((b) => b.toJson()).toList(),
      'paid_for': paidFor.map((b) => b.toJson()).toList(),
      'created': created,
    });
    _check(data);
    return ExpenseModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    await _client.delete('/expense/$expenseId');
  }

  @override
  Future<List<CommentModel>> fetchComments(String expenseId) async {
    final data = await _client.get('/comment/expense/$expenseId');
    _check(data);
    return (data['data'] as List)
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> postComment({
    required String expenseId, required String tripId,
    required String title, required String body,
  }) async {
    await _client.post('/comment/new', {
      'entity_type': 'expense', 'entity_id': expenseId,
      'trip': tripId, 'title': title, 'body': body,
    });
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _client.delete('/comment/$commentId');
  }

  void _check(Map<String, dynamic> data) {
    if (data['status'] != 200) {
      throw ServerException(data['message']?.toString() ?? 'Server error');
    }
  }
}
