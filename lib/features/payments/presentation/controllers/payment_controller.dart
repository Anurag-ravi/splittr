import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/providers/domain_providers.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/payments/presentation/states/payment_state.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';

class PaymentNotifier extends AsyncNotifier<PaymentSavedData?> {
  @override
  Future<PaymentSavedData?> build() async => null;

  Future<void> record({
    required String fromTripUserId,
    required String toTripUserId,
    required double amount,
    required Map<String, TripMemberModel> tripUserMap,
    required DateTime created,
    String? paymentId,
  }) async {
    state = const AsyncLoading();
    final tripId = tripUserMap[fromTripUserId]!.trip;

    final result = await ref.read(savePaymentUseCaseProvider).call(
          fromMemberId: fromTripUserId,
          toMemberId: toTripUserId,
          amount: amount,
          tripId: tripId,
          created: created,
          paymentId: paymentId,
        );

    if (result.isFailure) {
      state = AsyncError(result.failure.message, StackTrace.current);
      return;
    }

    final entity = result.value;
    final payment = PaymentModel(
      id: entity.id,
      trip: entity.tripId,
      amount: entity.amount,
      created: entity.created,
      by: entity.byMemberId,
      to: entity.toMemberId,
    );
    final trip = HiveBoxes.trips.get(payment.trip);
    if (trip != null) {
      final updated = trip.copyWith(
        payments: [
          ...trip.payments.where((p) => p.id != payment.id),
          payment,
        ],
      );
      await HiveBoxes.trips.put(trip.id, updated);
    }
    state = AsyncData(PaymentSavedData(payment));
  }

  Future<void> delete(String paymentId, String tripId) async {
    state = const AsyncLoading();
    final result =
        await ref.read(deletePaymentUseCaseProvider).call(paymentId, tripId);
    if (result.isFailure) {
      state = AsyncError(result.failure.message, StackTrace.current);
      return;
    }
    final trip = HiveBoxes.trips.get(tripId);
    if (trip != null) {
      final updated = trip.copyWith(
        payments: trip.payments.where((p) => p.id != paymentId).toList(),
      );
      await HiveBoxes.trips.put(tripId, updated);
    }
    state = const AsyncData(null);
  }

  void reset() => state = const AsyncData(null);
}
