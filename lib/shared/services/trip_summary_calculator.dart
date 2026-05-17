import 'package:flutter/material.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/amount_formatter.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/shared/models/trip_summary.dart';

abstract final class TripSummaryCalculator {
  static TripSummary calculate({
    required TripModel trip,
    required String userId,
  }) {
    String currentTripUser = '';
    double paidByMe = 0, paidForMe = 0, total = 0;
    final Map<String, TripMemberModel> tripUserMap = {};
    final Map<String, double> tripUserNet = {};

    for (final tu in trip.users) {
      if (tu.user == userId) currentTripUser = tu.id;
      tripUserMap[tu.id] = tu;
      tripUserNet[tu.id] = 0;
    }

    for (final expense in trip.expenses) {
      total += expense.amount;
      for (final paid in expense.paidBy) {
        if (paid.user == currentTripUser) paidByMe += paid.amount;
        tripUserNet[paid.user] = (tripUserNet[paid.user] ?? 0) + paid.amount;
      }
      for (final paid in expense.paidFor) {
        if (paid.user == currentTripUser) paidForMe += paid.amount;
        tripUserNet[paid.user] = (tripUserNet[paid.user] ?? 0) - paid.amount;
      }
    }

    for (final payment in trip.payments) {
      if (payment.by == currentTripUser) paidByMe += payment.amount;
      if (payment.to == currentTripUser) paidForMe += payment.amount;
      tripUserNet[payment.by] = (tripUserNet[payment.by] ?? 0) + payment.amount;
      tripUserNet[payment.to] = (tripUserNet[payment.to] ?? 0) - payment.amount;
    }

    String involvedText;
    Color textColor;
    bool free;

    if (paidByMe.toStringAsFixed(2) == paidForMe.toStringAsFixed(2)) {
      free = true;
      involvedText = 'You are all settled up in this group';
      textColor = AppColors.textPrimary;
    } else if (paidByMe >= paidForMe) {
      free = false;
      involvedText =
          'You are owed ₹${(paidByMe - paidForMe).toStringAsFixed(2)} overall';
      textColor = AppColors.primary;
    } else {
      free = false;
      involvedText =
          'You owe ₹${(paidForMe - paidByMe).toStringAsFixed(2)} overall';
      textColor = AppColors.amber;
    }

    final deletable =
        tripUserNet.values.every((v) => AmountFormatter.round2(v) == 0);

    return TripSummary(
      free: free,
      deletable: deletable,
      involvedText: involvedText,
      textColor: textColor,
      paidByMe: paidByMe,
      paidForMe: paidForMe,
      total: total,
      currentTripUser: currentTripUser,
      tripUserMap: tripUserMap,
    );
  }
}
