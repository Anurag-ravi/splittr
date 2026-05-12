import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/expense.dart';
import 'package:splittr/models/payment.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/models/tripuser.dart';
import 'package:splittr/pages/expensePage.dart';
import 'package:splittr/pages/paymentPage.dart';
import 'package:splittr/pages/tripPage.dart';
import 'package:splittr/utilities/boxes.dart';
import 'package:splittr/utilities/trip_service.dart';

class ActivityNavigator {
  static Future<void> navigate(
      BuildContext context, String entityId, String entityType) async {
    switch (entityType) {
      case 'expense':
        await _toExpense(context, entityId);
        break;
      case 'payment':
        await _toPayment(context, entityId);
        break;
      case 'trip':
        await _toTrip(context, entityId);
        break;
    }
  }

  static Map<String, TripUser> _buildTripUserMap(TripModel trip) =>
      {for (var tu in trip.users) tu.id: tu};

  static ({ExpenseModel? expense, TripModel? trip}) _findExpense(
      String expenseId) {
    for (final trip in Boxes.getTrips().values) {
      for (final e in trip.expenses) {
        if (e.id == expenseId) return (expense: e, trip: trip);
      }
    }
    return (expense: null, trip: null);
  }

  static ({PaymentModel? payment, TripModel? trip}) _findPayment(
      String paymentId) {
    for (final trip in Boxes.getTrips().values) {
      for (final p in trip.payments) {
        if (p.id == paymentId) return (payment: p, trip: trip);
      }
    }
    return (payment: null, trip: null);
  }

  static Future<SharedPreferences?> _prefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('url') == null || prefs.getString('token') == null) {
      return null;
    }
    return prefs;
  }

  static void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // --- Trip ---

  static Future<void> _toTrip(BuildContext context, String tripId) async {
    TripModel? trip = Boxes.getTrips().get(tripId);

    if (trip == null) {
      final prefs = await _prefs();
      if (prefs == null || !context.mounted) return;
      trip = await TripService.fetchAndCacheTrip(tripId, prefs, context);
    }

    if (!context.mounted) return;
    if (trip == null) {
      _showSnackbar(context, 'Could not load this trip');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => TripPage(id: tripId, trip: trip!)),
    );
  }

  // --- Expense ---

  static Future<void> _toExpense(BuildContext context, String expenseId) async {
    var found = _findExpense(expenseId);

    if (found.expense == null) {
      final prefs = await _prefs();
      if (prefs == null || !context.mounted) return;
      await TripService.fetchAndCacheAllTrips(prefs, context);
      if (!context.mounted) return;
      found = _findExpense(expenseId);
    }

    if (!context.mounted) return;
    if (found.expense == null || found.trip == null) {
      _showSnackbar(context, 'Could not find this expense');
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ExpensePage(
        expense: found.expense!,
        trip: found.trip!,
        tripUserMap: _buildTripUserMap(found.trip!),
      ),
    ));
  }

  // --- Payment ---

  static Future<void> _toPayment(BuildContext context, String paymentId) async {
    var found = _findPayment(paymentId);

    if (found.payment == null) {
      final prefs = await _prefs();
      if (prefs == null || !context.mounted) return;
      await TripService.fetchAndCacheAllTrips(prefs, context);
      if (!context.mounted) return;
      found = _findPayment(paymentId);
    }

    if (!context.mounted) return;
    if (found.payment == null || found.trip == null) {
      _showSnackbar(context, 'Could not find this payment');
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => PaymentView(
        payment: found.payment!,
        tripUserMap: _buildTripUserMap(found.trip!),
      ),
    ));
  }
}
