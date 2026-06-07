import 'package:splittr/core/errors/exceptions.dart';
import 'package:splittr/core/errors/failures.dart';
import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/expenses/domain/entities/expense_entity.dart';
import 'package:splittr/features/payments/data/datasources/payment_remote_datasource.dart';
import 'package:splittr/features/payments/domain/entities/payment_entity.dart';
import 'package:splittr/features/payments/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements IPaymentRepository {
  const PaymentRepositoryImpl(this._remote);
  final IPaymentRemoteDatasource _remote;

  @override
  Future<Result<PaymentEntity>> createPayment({
    required String fromMemberId,
    required String toMemberId,
    required double amount,
    required String tripId,
    required DateTime created,
  }) async {
    try {
      final model = await _remote.createPayment(
        fromMemberId: fromMemberId,
        toMemberId: toMemberId,
        amount: amount,
        tripId: tripId,
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
  Future<Result<PaymentEntity>> updatePayment({
    required String paymentId,
    required double amount,
    required DateTime created,
  }) async {
    try {
      final model = await _remote.updatePayment(
        paymentId: paymentId,
        amount: amount,
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
  Future<Result<void>> deletePayment(String paymentId, String tripId) async {
    try {
      await _remote.deletePayment(paymentId);
      return ok(null);
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<CommentEntity>>> fetchComments(String paymentId) async {
    try {
      final models = await _remote.fetchComments(paymentId);
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
    required String paymentId,
    required String tripId,
    required String title,
    required String body,
  }) async {
    try {
      await _remote.postComment(
          paymentId: paymentId, tripId: tripId, title: title, body: body);
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
