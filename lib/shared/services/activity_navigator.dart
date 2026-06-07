import 'package:flutter/material.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:splittr/features/expenses/presentation/screens/expense_screen.dart';
import 'package:splittr/features/payments/presentation/screens/payment_screen.dart';
import 'package:splittr/features/payments/presentation/screens/record_payment_screen.dart';
import 'package:splittr/features/trips/presentation/screens/trip_screen.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/shared/services/trip_service.dart';

/// Routes push-notification taps and activity-feed taps to the correct screen.
abstract final class ActivityNavigator {
  static Future<void> navigate(
    BuildContext context,
    String entityId,
    String entityType,
  ) async {
    switch (entityType) {
      case 'expense':
        await _toExpense(context, entityId);
      case 'payment':
        await _toPayment(context, entityId);
      case 'trip':
        await _toTrip(context, entityId);
    }
  }

  // ---------------------------------------------------------------------------

  static Map<String, TripMemberModel> _userMap(TripModel t) =>
      {for (final u in t.users) u.id: u};

  static ({ExpenseModel? expense, TripModel? trip}) _findExpense(String id) {
    for (final trip in HiveBoxes.trips.values) {
      for (final e in trip.expenses) {
        if (e.id == id) return (expense: e, trip: trip);
      }
    }
    return (expense: null, trip: null);
  }

  static ({PaymentModel? payment, TripModel? trip}) _findPayment(String id) {
    for (final trip in HiveBoxes.trips.values) {
      for (final p in trip.payments) {
        if (p.id == id) return (payment: p, trip: trip);
      }
    }
    return (payment: null, trip: null);
  }

  static void _snack(BuildContext ctx, String msg) =>
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 4),
      ));

  // ---------------------------------------------------------------------------

  static Future<void> _toTrip(BuildContext context, String tripId) async {
    TripModel? trip = HiveBoxes.trips.get(tripId);
    if (trip == null) {
      if (!context.mounted) return;
      trip = await TripService.fetchAndCacheTrip(tripId, context);
    }
    if (!context.mounted) return;
    if (trip == null) {
      _snack(context, 'Could not load this trip');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TripScreen(id: tripId, trip: trip!)),
    );
  }

  static Future<void> _toExpense(BuildContext context, String expenseId) async {
    var found = _findExpense(expenseId);
    if (found.expense == null) {
      if (!context.mounted) return;
      await TripService.fetchAndCacheAllTrips(context);
      if (!context.mounted) return;
      found = _findExpense(expenseId);
    }
    if (!context.mounted) return;
    if (found.expense == null || found.trip == null) {
      _snack(context, 'Could not find this expense');
      return;
    }
    final tripUserMap = _userMap(found.trip!);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseScreen(
          expense: found.expense!,
          trip: found.trip!,
          tripUserMap: tripUserMap,
          addExpenseBuilder: (ctx) => AddExpenseScreen(
            trip: found.trip!,
            updating: true,
            expense: found.expense,
          ),
        ),
      ),
    );
  }

  static Future<void> _toPayment(BuildContext context, String paymentId) async {
    var found = _findPayment(paymentId);
    if (found.payment == null) {
      if (!context.mounted) return;
      await TripService.fetchAndCacheAllTrips(context);
      if (!context.mounted) return;
      found = _findPayment(paymentId);
    }
    if (!context.mounted) return;
    if (found.payment == null || found.trip == null) {
      _snack(context, 'Could not find this payment');
      return;
    }
    final tripUserMap = _userMap(found.trip!);
    final payment = found.payment!;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          payment: payment,
          tripUserMap: tripUserMap,
          paymentPageBuilder: (ctx) => RecordPaymentScreen(
            from: payment.by,
            to: payment.to,
            amount: payment.amount,
            tripUserMap: tripUserMap,
            updating: true,
            paymentId: payment.id,
            created: payment.created,
          ),
        ),
      ),
    );
  }
}
