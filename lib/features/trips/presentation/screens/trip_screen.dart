import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:splittr/features/expenses/presentation/screens/expense_screen.dart';
import 'package:splittr/features/payments/presentation/screens/balances_screen.dart';
import 'package:splittr/features/payments/presentation/screens/choose_payment_by_screen.dart';
import 'package:splittr/features/payments/presentation/screens/payment_screen.dart';
import 'package:splittr/features/payments/presentation/screens/record_payment_screen.dart';
import 'package:splittr/features/payments/presentation/screens/settle_up_screen.dart';
import 'package:splittr/features/trips/presentation/controllers/trip_controller.dart';
import 'package:splittr/features/trips/presentation/providers/trip_providers.dart';
import 'package:splittr/features/trips/presentation/screens/totals_screen.dart';
import 'package:splittr/features/trips/presentation/screens/trip_settings_screen.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/shared/models/trip_summary.dart';
import 'package:splittr/shared/services/excel_export_service.dart';

class Transaction {
  final bool isExpense;
  final DateTime date;
  final ExpenseModel? expense;
  final PaymentModel? payment;
  final bool isMonth;
  final String month;
  final bool isLoading;

  const Transaction(this.isExpense, this.date, this.expense, this.payment,
      {this.isMonth = false, this.month = '', this.isLoading = false});
}

class TripScreen extends ConsumerStatefulWidget {
  const TripScreen({super.key, required this.id, required this.trip});

  final String id;
  final TripModel trip;

  @override
  ConsumerState<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends ConsumerState<TripScreen> {
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripProvider(widget.trip));
    final notifier = ref.read(tripProvider(widget.trip).notifier);

    if (tripAsync.isLoading && !tripAsync.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final data = tripAsync.value;
    if (data == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final trip = data.trip;
    final summary = data.summary;
    final isRefreshing = tripAsync.isLoading;
    final transactions = _buildTransactions(trip);

    return RefreshIndicator(
      onRefresh: () => notifier.refresh(),
      child: Scaffold(
        backgroundColor: AppColors.scaffoldDark,
        appBar: AppBar(
          flexibleSpace: const Opacity(
            opacity: 0.7,
            child: Image(
              image: AssetImage('assets/images/trip3.png'),
              fit: BoxFit.cover,
            ),
          ),
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TripSettingsScreen(
                      trip: trip,
                      free: summary.free,
                      currentUserID:
                          summary.tripUserMap[summary.currentTripUser]!.user,
                      deletable: summary.deletable,
                    ),
                  ),
                );
                if (!mounted) return;
                notifier.refresh();
              },
            ),
          ],
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.view_list,
          overlayColor: Colors.transparent,
          animatedIconTheme: const IconThemeData(size: 22),
          backgroundColor: AppColors.primary,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.payment),
              backgroundColor: AppColors.primary,
              label: 'Add Payment',
              labelStyle: const TextStyle(fontSize: 12),
              onTap: () async {
                Haptics.medium();
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ChoosePaymentByScreen(tripUserMap: summary.tripUserMap),
                  ),
                );
                if (!mounted) return;
                notifier.applyPaymentChanged();
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.receipt_outlined),
              backgroundColor: AppColors.primary,
              label: 'Add Expense',
              labelStyle: const TextStyle(fontSize: 12),
              onTap: () async {
                Haptics.medium();
                final res = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => AddExpenseScreen(trip: trip)),
                );
                if (!mounted || res == null || res['changed'] != true) {
                  return;
                }
                notifier.applyExpenseAdded(res['expense'] as ExpenseModel);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView.builder(
            itemCount: transactions.length + 4 + (isRefreshing ? 1 : 0),
            itemBuilder: (_, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(left: 30, top: 20),
                  child: Text(trip.name,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 20)),
                );
              }
              if (index == 1) {
                return Padding(
                  padding: const EdgeInsets.only(left: 30, top: 10),
                  child: Text(summary.involvedText,
                      style: TextStyle(color: summary.textColor, fontSize: 17)),
                );
              }
              if (index == 2) {
                return Padding(
                  padding: const EdgeInsets.only(left: 8, top: 20, bottom: 30),
                  child: SizedBox(
                    height: 35,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _actionBtn('Settle up', AppColors.amber, () async {
                          Haptics.medium();
                          final res = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SettleUpScreen(
                                  trip: trip, tripUserMap: summary.tripUserMap),
                            ),
                          );
                          if (!mounted) return;
                          if (res == true) {
                            notifier.applyPaymentChanged();
                          }
                        }),
                        _actionBtn('Balances', AppColors.surfaceDark, () async {
                          Haptics.medium();
                          final res = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BalancesScreen(
                                  trip: trip, tripUserMap: summary.tripUserMap),
                            ),
                          );
                          if (!mounted) return;
                          if (res == true) {
                            notifier.applyPaymentChanged();
                          }
                        }),
                        _actionBtn('Totals', AppColors.surfaceDark, () {
                          Haptics.medium();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TotalsScreen(
                                name: trip.name,
                                paidByMe: summary.paidByMe,
                                paidForMe: summary.paidForMe,
                                total: summary.total,
                              ),
                            ),
                          );
                        }),
                        _actionBtn(_exporting ? 'Exporting' : 'Export',
                            AppColors.surfaceDark, () async {
                          setState(() => _exporting = true);
                          final snack = await ExcelExportService.export(
                              trip, summary.tripUserMap);
                          setState(() => _exporting = false);
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(snack);
                        }),
                      ],
                    ),
                  ),
                );
              }
              if (isRefreshing && index == 3) {
                return const LinearProgressIndicator(
                    color: AppColors.primary,
                    backgroundColor: Colors.transparent);
              }
              if (transactions.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Center(
                    child: Text(
                      index == 3
                          ? 'No Expenses or Payments yet!'
                          : 'Add Expenses or Payments to get started!',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                );
              }
              final offset = isRefreshing ? 4 : 3;
              final lastIdx = transactions.length + offset;
              if (index == lastIdx) {
                return const Padding(
                    padding: EdgeInsets.only(bottom: 50), child: SizedBox());
              }
              final idx = index - offset;
              if (idx < 0 || idx >= transactions.length) {
                return const SizedBox.shrink();
              }
              final txn = transactions[idx];
              if (txn.isMonth) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 8),
                  child: Text(txn.month,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 15)),
                );
              }
              return txn.isExpense
                  ? _expenseTile(context, txn, trip, summary, notifier)
                  : _paymentTile(context, txn, summary, notifier);
            },
          ),
        ),
      ),
    );
  }

  List<Transaction> _buildTransactions(TripModel trip) {
    final temp = [
      ...trip.expenses.map((e) => Transaction(true, e.created, e, null)),
      ...trip.payments.map((p) => Transaction(false, p.created, null, p)),
    ]..sort((a, b) => b.date.compareTo(a.date));

    final result = <Transaction>[];
    for (int i = 0; i < temp.length; i++) {
      final cur = temp[i];
      final label = '${_months[cur.date.month - 1]} ${cur.date.year}';
      if (i == 0 ||
          cur.date.month != temp[i - 1].date.month ||
          cur.date.year != temp[i - 1].date.year) {
        result.add(Transaction(false, cur.date, null, null,
            isMonth: true, month: label));
      }
      result.add(cur);
    }
    return result;
  }

  Widget _actionBtn(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: const Color(0xffa0a0a0), width: 0.5),
          ),
          child: Center(
            child: Text(text,
                style: const TextStyle(color: Colors.white, fontSize: 14)),
          ),
        ),
      ),
    );
  }

  Widget _paymentTile(
    BuildContext context,
    Transaction txn,
    TripSummary summary,
    TripNotifier notifier,
  ) {
    final payment = txn.payment!;
    final byName = summary.tripUserMap[payment.by]?.name ?? 'Unknown';
    final toName = summary.tripUserMap[payment.to]?.name ?? 'Unknown';
    return GestureDetector(
      onTap: () async {
        Haptics.medium();
        final res = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              payment: payment,
              tripUserMap: summary.tripUserMap,
              paymentPageBuilder: (ctx) => RecordPaymentScreen(
                from: payment.by,
                to: payment.to,
                amount: payment.amount,
                tripUserMap: summary.tripUserMap,
                updating: true,
                paymentId: payment.id,
                created: payment.created,
              ),
            ),
          ),
        );
        if (!mounted) return;
        if (res == true) notifier.applyPaymentChanged();
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(children: [
                Text(txn.date.day.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
                Text(_months[txn.date.month - 1],
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
              ]),
            ),
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset('assets/categories/payment.png',
                    height: 30, width: 30),
              ),
            ),
            Expanded(
              flex: 20,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  '$byName paid $toName ₹${payment.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _expenseTile(
    BuildContext context,
    Transaction txn,
    TripModel trip,
    TripSummary summary,
    TripNotifier notifier,
  ) {
    final expense = txn.expense!;
    double paidByMe = 0, paidForMe = 0;
    for (final x in expense.paidBy) {
      if (x.user == summary.currentTripUser) paidByMe += x.amount;
    }
    for (final x in expense.paidFor) {
      if (x.user == summary.currentTripUser) paidForMe += x.amount;
    }

    String involved = '';
    String amount = '';
    Color textColor = AppColors.textPrimary;

    if (paidByMe == 0 && paidForMe == 0) {
      involved = 'not involved';
    } else if (paidByMe >= paidForMe) {
      involved = 'you owed';
      textColor = AppColors.primary;
      amount = (paidByMe - paidForMe).toStringAsFixed(2);
    } else {
      involved = 'you borrowed';
      textColor = AppColors.amber;
      amount = (paidForMe - paidByMe).toStringAsFixed(2);
    }

    return GestureDetector(
      onTap: () async {
        Haptics.medium();
        final res = await Navigator.push<Map<String, dynamic>>(
          context,
          MaterialPageRoute(
            builder: (_) => ExpenseScreen(
              expense: expense,
              tripUserMap: summary.tripUserMap,
              trip: trip,
              addExpenseBuilder: (ctx) => AddExpenseScreen(
                trip: trip,
                updating: true,
                expense: expense,
              ),
            ),
          ),
        );
        if (!mounted || res == null || res['changed'] != true) return;
        if (res['expense'] == null) {
          notifier.applyExpenseDeleted(expense.id);
        } else {
          notifier.applyExpenseUpdated(res['expense'] as ExpenseModel);
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(children: [
                Text(txn.date.day.toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
                Text(_months[txn.date.month - 1],
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
              ]),
            ),
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset('assets/categories/${expense.category}.png',
                    height: 45, width: 45),
              ),
            ),
            Expanded(
              flex: 15,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(expense.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis)),
              ),
            ),
            Expanded(
              flex: 6,
              child: Column(children: [
                Text(involved,
                    style: TextStyle(color: textColor, fontSize: 10)),
                Text(amount, style: TextStyle(color: textColor, fontSize: 12)),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
