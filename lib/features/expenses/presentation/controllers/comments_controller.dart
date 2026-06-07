import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/providers/domain_providers.dart';
import 'package:splittr/features/expenses/data/models/comment_model.dart';

/// Keyed by entity ID. Manages comments for one expense or payment.
class CommentsNotifier
    extends FamilyAsyncNotifier<List<CommentModel>, String> {
  @override
  Future<List<CommentModel>> build(String entityId) async => [];

  Future<void> refreshForExpense(String expenseId) async {
    state = const AsyncLoading();
    final result =
        await ref.read(fetchExpenseCommentsUseCaseProvider).call(expenseId);
    state = result.when(
      success: (entities) => AsyncData(
        entities.map(_entityToModel).toList(),
      ),
      onFailure: (_) => const AsyncData([]),
    );
  }

  Future<void> refreshForPayment(String paymentId) async {
    state = const AsyncLoading();
    final result =
        await ref.read(fetchPaymentCommentsUseCaseProvider).call(paymentId);
    state = result.when(
      success: (entities) => AsyncData(
        entities.map(_entityToModel).toList(),
      ),
      onFailure: (_) => const AsyncData([]),
    );
  }

  Future<void> postOnExpense({
    required String text,
    required String expenseId,
    required String tripId,
    required String expenseName,
  }) async {
    final current = state.value ?? [];
    state = const AsyncLoading();
    await ref.read(postExpenseCommentUseCaseProvider).call(
          expenseId: expenseId,
          tripId: tripId,
          expenseName: expenseName,
          body: text,
        );
    // Re-fetch after post
    final result =
        await ref.read(fetchExpenseCommentsUseCaseProvider).call(expenseId);
    state = result.when(
      success: (entities) => AsyncData(entities.map(_entityToModel).toList()),
      onFailure: (_) => AsyncData(current),
    );
  }

  Future<void> postOnPayment({
    required String text,
    required String paymentId,
    required String tripId,
    required String title,
  }) async {
    final current = state.value ?? [];
    state = const AsyncLoading();
    await ref.read(postPaymentCommentUseCaseProvider).call(
          paymentId: paymentId,
          tripId: tripId,
          title: title,
          body: text,
        );
    final result =
        await ref.read(fetchPaymentCommentsUseCaseProvider).call(paymentId);
    state = result.when(
      success: (entities) => AsyncData(entities.map(_entityToModel).toList()),
      onFailure: (_) => AsyncData(current),
    );
  }

  Future<void> deleteFromExpense(String commentId, String expenseId) async {
    await ref.read(deleteExpenseCommentUseCaseProvider).call(commentId);
    final current = state.value ?? [];
    state = AsyncData(current.where((c) => c.id != commentId).toList());
    // Re-sync with server in background
    final result =
        await ref.read(fetchExpenseCommentsUseCaseProvider).call(expenseId);
    result.when(
      success: (entities) =>
          state = AsyncData(entities.map(_entityToModel).toList()),
      onFailure: (_) {},
    );
  }

  Future<void> deleteFromPayment(String commentId, String paymentId) async {
    await ref.read(deletePaymentCommentUseCaseProvider).call(commentId);
    final current = state.value ?? [];
    state = AsyncData(current.where((c) => c.id != commentId).toList());
    final result =
        await ref.read(fetchPaymentCommentsUseCaseProvider).call(paymentId);
    result.when(
      success: (entities) =>
          state = AsyncData(entities.map(_entityToModel).toList()),
      onFailure: (_) {},
    );
  }

  // Bridge: domain CommentEntity → new CommentModel for UI consumption.
  CommentModel _entityToModel(dynamic e) {
    return CommentModel(
      id: e.id,
      entityType: e.entityType,
      entityId: e.entityId,
      trip: e.tripId,
      type: e.type,
      title: e.title,
      body: e.body,
      createdAt: e.createdAt,
      createdById: e.createdById,
      createdByUser: e.createdByUser,
      createdByName: e.createdByName,
      createdByDp: e.createdByDp,
      diff: e.diff,
    );
  }
}
