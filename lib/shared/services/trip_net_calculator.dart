import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/shared/models/trip_net_summary.dart';

abstract final class TripNetCalculator {
  static TripNetSummary calculate({
    required TripModel trip,
    required String currentUserId,
  }) {
    String currentTripUserId = '';
    for (final user in trip.users) {
      if (user.user == currentUserId) {
        currentTripUserId = user.id;
        break;
      }
    }

    double paidByMe = 0, paidForMe = 0;

    for (final expense in trip.expenses) {
      for (final paid in expense.paidBy) {
        if (paid.user == currentTripUserId) paidByMe += paid.amount;
      }
      for (final paid in expense.paidFor) {
        if (paid.user == currentTripUserId) paidForMe += paid.amount;
      }
    }

    for (final payment in trip.payments) {
      if (payment.by == currentTripUserId) paidByMe += payment.amount;
      if (payment.to == currentTripUserId) paidForMe += payment.amount;
    }

    final net = paidByMe - paidForMe;

    if (net.abs() < 0.01) {
      return const TripNetSummary(
        message: 'You are all settled up in this group',
        color: AppColors.textPrimary,
        amount: 0,
        settled: true,
      );
    }

    if (net > 0) {
      return TripNetSummary(
        message: 'You are owed ₹${net.toStringAsFixed(2)} overall',
        color: AppColors.primary,
        amount: net,
        settled: false,
      );
    }

    return TripNetSummary(
      message: 'You owe ₹${net.abs().toStringAsFixed(2)} overall',
      color: AppColors.amber,
      amount: net.abs(),
      settled: false,
    );
  }
}
