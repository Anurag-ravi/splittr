import 'package:flutter/material.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';

class PaymentRepository {
  const PaymentRepository();

  Future<Map<String, dynamic>?> createPayment(
    BuildContext context, {
    required String fromTripUserId,
    required String toTripUserId,
    required double amount,
    required String tripId,
    required String created,
  }) =>
      AppHttpClient.post(context, '/payment/new', {
        'by': fromTripUserId,
        'to': toTripUserId,
        'amount': amount,
        'trip_id': tripId,
        'created': created,
      });

  Future<Map<String, dynamic>?> updatePayment(
    BuildContext context, {
    required String paymentId,
    required double amount,
    required String created,
  }) =>
      AppHttpClient.post(context, '/payment/$paymentId', {
        'amount': amount,
        'created': created,
      });

  Future<Map<String, dynamic>?> deletePayment(
          BuildContext context, String paymentId) =>
      AppHttpClient.delete(context, '/payment/$paymentId');

  Future<void> cachePayment(PaymentModel payment) async {
    final trip = HiveBoxes.trips.get(payment.trip);
    if (trip == null) return;
    final updated = trip.copyWith(
      payments: [
        ...trip.payments.where((p) => p.id != payment.id),
        payment,
      ],
    );
    await HiveBoxes.trips.put(payment.trip, updated);
  }

  Future<void> removeFromCache(String paymentId, String tripId) async {
    final trip = HiveBoxes.trips.get(tripId);
    if (trip == null) return;
    final updated = trip.copyWith(
      payments: trip.payments.where((p) => p.id != paymentId).toList(),
    );
    await HiveBoxes.trips.put(tripId, updated);
  }
}
