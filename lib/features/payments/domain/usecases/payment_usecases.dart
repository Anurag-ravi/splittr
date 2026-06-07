import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/expenses/domain/entities/expense_entity.dart';
import 'package:splittr/features/payments/domain/entities/payment_entity.dart';
import 'package:splittr/features/payments/domain/repositories/payment_repository.dart';

class SavePaymentUseCase {
  const SavePaymentUseCase(this._repo);
  final IPaymentRepository _repo;

  Future<Result<PaymentEntity>> call({
    required String fromMemberId,
    required String toMemberId,
    required double amount,
    required String tripId,
    required DateTime created,
    String? paymentId,
  }) {
    if (paymentId != null) {
      return _repo.updatePayment(
          paymentId: paymentId, amount: amount, created: created);
    }
    return _repo.createPayment(
      fromMemberId: fromMemberId, toMemberId: toMemberId,
      amount: amount, tripId: tripId, created: created,
    );
  }
}

class DeletePaymentUseCase {
  const DeletePaymentUseCase(this._repo);
  final IPaymentRepository _repo;
  Future<Result<void>> call(String paymentId, String tripId) =>
      _repo.deletePayment(paymentId, tripId);
}

class FetchPaymentCommentsUseCase {
  const FetchPaymentCommentsUseCase(this._repo);
  final IPaymentRepository _repo;
  Future<Result<List<CommentEntity>>> call(String paymentId) =>
      _repo.fetchComments(paymentId);
}

class PostPaymentCommentUseCase {
  const PostPaymentCommentUseCase(this._repo);
  final IPaymentRepository _repo;
  Future<Result<void>> call({
    required String paymentId,
    required String tripId,
    required String title,
    required String body,
  }) =>
      _repo.postComment(
          paymentId: paymentId, tripId: tripId, title: title, body: body);
}

class DeletePaymentCommentUseCase {
  const DeletePaymentCommentUseCase(this._repo);
  final IPaymentRepository _repo;
  Future<Result<void>> call(String commentId) => _repo.deleteComment(commentId);
}
