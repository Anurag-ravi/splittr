import 'package:collection/collection.dart';
import 'package:splittr/features/expenses/data/models/split_entry_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class Triad {
  final String from;
  final String to;
  final double amount;

  const Triad(this.from, this.to, this.amount);
}

class Balance {
  final String user;
  final double amount;
  final bool isPositive;
  final List<SplitEntryModel> paid;

  Balance(this.user, this.amount, this.isPositive, this.paid);
}

abstract final class SettleUpService {
  /// Returns the minimum set of transactions to settle all debts.
  static List<Triad> triads(TripModel trip) => _compute(trip, triadsOnly: true);

  /// Returns a per-member balance list annotated with who-owes-whom.
  static List<Balance> balances(TripModel trip) =>
      _compute(trip, triadsOnly: false);

  // ---------------------------------------------------------------------------

  static dynamic _compute(TripModel trip, {required bool triadsOnly}) {
    final Map<String, double> net = {for (final m in trip.users) m.id: 0.0};

    for (final expense in trip.expenses) {
      for (final by in expense.paidBy) {
        net[by.user] = (net[by.user] ?? 0) + by.amount;
      }
      for (final fr in expense.paidFor) {
        net[fr.user] = (net[fr.user] ?? 0) - fr.amount;
      }
    }
    for (final payment in trip.payments) {
      net[payment.by] = (net[payment.by] ?? 0) + payment.amount;
      net[payment.to] = (net[payment.to] ?? 0) - payment.amount;
    }

    final pos = PriorityQueue<MapEntry<String, double>>(
        (a, b) => a.value.compareTo(b.value));
    final neg = PriorityQueue<MapEntry<String, double>>(
        (a, b) => a.value.compareTo(b.value));
    final List<Balance> balancesList = [];

    for (final entry in net.entries) {
      final v = double.parse(entry.value.toStringAsFixed(2));
      if (v > 0) {
        pos.add(MapEntry(entry.key, v));
        balancesList.add(Balance(entry.key, v, true, []));
      } else if (v < 0) {
        neg.add(MapEntry(entry.key, -v));
        balancesList.add(Balance(entry.key, -v, false, []));
      } else {
        balancesList.add(Balance(entry.key, 0, true, []));
      }
    }

    final List<Triad> transactions = [];
    while (pos.isNotEmpty && neg.isNotEmpty) {
      final p = pos.removeFirst();
      final n = neg.removeFirst();
      final pp = double.parse(p.value.toStringAsFixed(2));
      final nn = double.parse(n.value.toStringAsFixed(2));
      if (pp > nn) {
        transactions.add(Triad(n.key, p.key, nn));
        pos.add(MapEntry(p.key, pp - nn));
      } else if (pp < nn) {
        transactions.add(Triad(n.key, p.key, pp));
        neg.add(MapEntry(n.key, nn - pp));
      } else {
        transactions.add(Triad(n.key, p.key, pp));
      }
    }

    if (triadsOnly) return transactions;

    for (final triad in transactions) {
      for (final balance in balancesList) {
        if (balance.user == triad.from) {
          balance.paid.add(SplitEntryModel(user: triad.to, amount: triad.amount));
        } else if (balance.user == triad.to) {
          balance.paid.add(SplitEntryModel(user: triad.from, amount: triad.amount));
        }
      }
    }
    return balancesList;
  }
}
