import 'package:flutter/material.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/features/expenses/data/models/comment_model.dart';

class CommentRepository {
  const CommentRepository();

  Future<List<CommentModel>?> fetchForExpense(
      BuildContext context, String expenseId) async {
    final data =
        await AppHttpClient.get(context, '/comment/expense/$expenseId');
    if (data == null || data['status'] != 200) return null;
    return (data['data'] as List)
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CommentModel>?> fetchForPayment(
      BuildContext context, String paymentId) async {
    final data =
        await AppHttpClient.get(context, '/comment/payment/$paymentId');
    if (data == null || data['status'] != 200) return null;
    return (data['data'] as List)
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>?> post(
    BuildContext context, {
    required String entityType,
    required String entityId,
    required String tripId,
    required String title,
    required String body,
  }) =>
      AppHttpClient.post(context, '/comment/new', {
        'entity_type': entityType,
        'entity_id': entityId,
        'trip': tripId,
        'title': title,
        'body': body,
      });

  Future<Map<String, dynamic>?> delete(
          BuildContext context, String commentId) =>
      AppHttpClient.delete(context, '/comment/$commentId');

  // Comments are no longer cached in Hive (new freezed models are immutable
  // and have no comments field). These are no-ops kept for API compatibility.
  Future<void> cacheExpenseComments(
      String expenseId, List<CommentModel> comments) async {}

  Future<void> cachePaymentComments(
      String paymentId, List<CommentModel> comments) async {}
}
