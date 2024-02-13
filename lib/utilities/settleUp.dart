import 'package:splittr/models/expense.dart';
import 'package:splittr/models/trip.dart';
import 'package:collection/collection.dart';

class Triad {
  String from;
  String to;
  double amount;
  Triad(this.from, this.to, this.amount);
}

class Balance {
  String user;
  double amount;
  bool isPositive;
  List<By> paid;

  Balance(this.user, this.amount, this.isPositive, this.paid);
}

dynamic settleUp(TripModel trip, {bool flag = false}) {
  Map<String, double> balances = {};
  for (var member in trip.users) {
    balances[member.id] = 0;
  }
  for (var expense in trip.expenses) {
    for (var by in expense.paid_by) {
      balances[by.user] = balances[by.user]! + by.amount;
    }
    for (var fr in expense.paid_for) {
      balances[fr.user] = balances[fr.user]! - fr.amount;
    }
  }
  for (var payment in trip.payments) {
    balances[payment.by] = balances[payment.by]! + payment.amount;
    balances[payment.to] = balances[payment.to]! - payment.amount;
  }
  var pos = PriorityQueue<MapEntry<String, double>>(
      (a, b) => a.value.compareTo(b.value));
  var neg = PriorityQueue<MapEntry<String, double>>(
      (a, b) => a.value.compareTo(b.value));

  List<Balance> balancesList = [];
  for (var entry in balances.entries) {
    if (double.parse(entry.value.toStringAsFixed(2)) > 0) {
      pos.add(
          MapEntry(entry.key, double.parse(entry.value.toStringAsFixed(2))));
      balancesList.add(Balance(
          entry.key, double.parse(entry.value.toStringAsFixed(2)), true, []));
    } else if (double.parse(entry.value.toStringAsFixed(2)) < 0) {
      neg.add(
          MapEntry(entry.key, -double.parse(entry.value.toStringAsFixed(2))));
      balancesList.add(Balance(
          entry.key, -double.parse(entry.value.toStringAsFixed(2)), false, []));
    } else {
      balancesList.add(Balance(entry.key, 0, true, []));
    }
  }

  List<Triad> transactions = [];
  while (pos.isNotEmpty && neg.isNotEmpty) {
    var p = pos.removeFirst();
    var n = neg.removeFirst();
    double pp = double.parse(p.value.toStringAsFixed(2));
    double nn = double.parse(n.value.toStringAsFixed(2));
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
  if (flag) {
    return transactions;
  }
  for (var transaction in transactions) {
    for (var balance in balancesList) {
      if (balance.user == transaction.from) {
        balance.paid.add(By(transaction.to, transaction.amount, 0));
      } else if (balance.user == transaction.to) {
        balance.paid.add(By(transaction.from, transaction.amount, 0));
      }
    }
  }
  return balancesList;
}
