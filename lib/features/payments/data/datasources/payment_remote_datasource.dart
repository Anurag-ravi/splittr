import 'package:splittr/core/errors/exceptions.dart';
import 'package:splittr/core/network/api_client.dart';
import 'package:splittr/features/expenses/data/models/comment_model.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';

abstract interface class IPaymentRemoteDatasource {
  Future<PaymentModel> createPayment({
    required String fromMemberId, required String toMemberId,
    required double amount, required String tripId, required String created,
  });
  Future<PaymentModel> updatePayment({
    required String paymentId, required double amount, required String created,
  });
  Future<void> deletePayment(String paymentId);
  Future<List<CommentModel>> fetchComments(String paymentId);
  Future<void> postComment({
    required String paymentId, required String tripId,
    required String title, required String body,
  });
  Future<void> deleteComment(String commentId);
}

class PaymentRemoteDatasource implements IPaymentRemoteDatasource {
  const PaymentRemoteDatasource(this._client);
  final ApiClient _client;

  @override
  Future<PaymentModel> createPayment({
    required String fromMemberId, required String toMemberId,
    required double amount, required String tripId, required String created,
  }) async {
    final data = await _client.post('/payment/new', {
      'by': fromMemberId, 'to': toMemberId,
      'amount': amount, 'trip_id': tripId, 'created': created,
    });
    _check(data);
    return PaymentModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<PaymentModel> updatePayment({
    required String paymentId, required double amount, required String created,
  }) async {
    final data = await _client.post(
        '/payment/$paymentId', {'amount': amount, 'created': created});
    _check(data);
    return PaymentModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<void> deletePayment(String paymentId) async {
    await _client.delete('/payment/$paymentId');
  }

  @override
  Future<List<CommentModel>> fetchComments(String paymentId) async {
    final data = await _client.get('/comment/payment/$paymentId');
    _check(data);
    return (data['data'] as List)
        .map((e) => CommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> postComment({
    required String paymentId, required String tripId,
    required String title, required String body,
  }) async {
    await _client.post('/comment/new', {
      'entity_type': 'payment', 'entity_id': paymentId,
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
