import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/expenses/domain/entities/expense_entity.dart';
import 'package:splittr/features/payments/domain/entities/payment_entity.dart';

abstract interface class IPaymentRepository {
  Future<Result<PaymentEntity>> createPayment({
    required String fromMemberId,
    required String toMemberId,
    required double amount,
    required String tripId,
    required DateTime created,
  });

  Future<Result<PaymentEntity>> updatePayment({
    required String paymentId,
    required double amount,
    required DateTime created,
  });

  Future<Result<void>> deletePayment(String paymentId, String tripId);

  Future<Result<List<CommentEntity>>> fetchComments(String paymentId);
  Future<Result<void>> postComment({
    required String paymentId,
    required String tripId,
    required String title,
    required String body,
  });
  Future<Result<void>> deleteComment(String commentId);
}
