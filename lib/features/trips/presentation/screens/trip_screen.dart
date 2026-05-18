// trip_screen.dart

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/core/widgets/category_icon.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:splittr/features/expenses/presentation/screens/expense_screen.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/payments/presentation/screens/balances_screen.dart';
import 'package:splittr/features/payments/presentation/screens/choose_payment_by_screen.dart';
import 'package:splittr/features/payments/presentation/screens/payment_screen.dart';
import 'package:splittr/features/payments/presentation/screens/record_payment_screen.dart';
import 'package:splittr/features/payments/presentation/screens/settle_up_screen.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/features/trips/presentation/controllers/trip_controller.dart';
import 'package:splittr/features/trips/presentation/providers/trip_providers.dart';
import 'package:splittr/features/trips/presentation/screens/totals_screen.dart';
import 'package:splittr/features/trips/presentation/screens/trip_settings_screen.dart';
import 'package:splittr/shared/models/trip_summary.dart';
import 'package:splittr/shared/services/excel_export_service.dart';

class Transaction {
  final bool isExpense;
  final DateTime date;
  final ExpenseModel? expense;
  final PaymentModel? payment;
  final bool isMonth;
  final String month;

  const Transaction(
    this.isExpense,
    this.date,
    this.expense,
    this.payment, {
    this.isMonth = false,
    this.month = '',
  });
}

class TripScreen extends ConsumerStatefulWidget {
  const TripScreen({
    super.key,
    required this.id,
    required this.trip,
  });

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
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final tripAsync = ref.watch(tripProvider(widget.trip));

    final notifier = ref.read(
      tripProvider(widget.trip).notifier,
    );

    if (tripAsync.isLoading && !tripAsync.hasValue) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final data = tripAsync.value;

    if (data == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final trip = data.trip;

    final summary = data.summary;

    final transactions = _buildTransactions(trip);

    final isRefreshing = tripAsync.isLoading;

    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: () => notifier.refresh(),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,

        // =====================
        // APP BAR
        // =====================

        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(
              190,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  18,
                  10,
                  18,
                  0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _topActionButton(
                          context,
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.pop(
                            context,
                          ),
                        ),
                        const Spacer(),
                        _topActionButton(
                          context,
                          icon: Icons.settings_rounded,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TripSettingsScreen(
                                  trip: trip,
                                  free: summary.free,
                                  currentUserID: summary
                                      .tripUserMap[summary.currentTripUser]!
                                      .user,
                                  deletable: summary.deletable,
                                ),
                              ),
                            );

                            if (!mounted) {
                              return;
                            }

                            notifier.refresh();
                          },
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      trip.name,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.78,
                      ),
                      decoration: BoxDecoration(
                        color: summary.textColor.withOpacity(
                          0.10,
                        ),
                        borderRadius: BorderRadius.circular(
                          20,
                        ),
                        border: Border.all(
                          color: summary.textColor.withOpacity(
                            0.14,
                          ),
                        ),
                      ),
                      child: Text(
                        summary.involvedText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: summary.textColor,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                  ],
                ),
              ),
            )),

        // =====================
        // FAB
        // =====================

        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(
                  0.28,
                ),
                blurRadius: 32,
                spreadRadius: -2,
              ),
            ],
          ),
          child: SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            overlayColor: Colors.black,
            overlayOpacity: 0.3,
            spacing: 14,
            spaceBetweenChildren: 12,
            animatedIconTheme: const IconThemeData(
              size: 22,
            ),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                24,
              ),
            ),
            children: [
              SpeedDialChild(
                child: const Icon(
                  Icons.currency_rupee_rounded,
                ),
                backgroundColor: colorScheme.primary,
                label: 'Add Payment',
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                onTap: () async {
                  Haptics.medium();

                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChoosePaymentByScreen(
                        tripUserMap: summary.tripUserMap,
                      ),
                    ),
                  );

                  if (!mounted) {
                    return;
                  }

                  notifier.applyPaymentChanged();
                },
              ),
              SpeedDialChild(
                child: const Icon(
                  Icons.receipt_long_rounded,
                ),
                backgroundColor: colorScheme.primary,
                label: 'Add Expense',
                labelStyle: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                onTap: () async {
                  Haptics.medium();

                  final res = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddExpenseScreen(
                        trip: trip,
                      ),
                    ),
                  );

                  if (!mounted || res == null || res['changed'] != true) {
                    return;
                  }

                  notifier.applyExpenseAdded(
                    res['expense'] as ExpenseModel,
                  );
                },
              ),
            ],
          ),
        ),

        // =====================
        // BODY
        // =====================

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                16,
              ),
              child: SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _modernActionButton(
                      context,
                      text: 'Settle up',
                      icon: Icons.handshake_rounded,
                      selected: true,
                      onTap: () async {
                        Haptics.medium();

                        final res = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SettleUpScreen(
                              trip: trip,
                              tripUserMap: summary.tripUserMap,
                            ),
                          ),
                        );

                        if (!mounted) {
                          return;
                        }

                        if (res == true) {
                          notifier.applyPaymentChanged();
                        }
                      },
                    ),
                    _modernActionButton(
                      context,
                      text: 'Balances',
                      icon: Icons.account_balance_wallet_rounded,
                      onTap: () async {
                        Haptics.medium();

                        final res = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BalancesScreen(
                              trip: trip,
                              tripUserMap: summary.tripUserMap,
                            ),
                          ),
                        );

                        if (!mounted) {
                          return;
                        }

                        if (res == true) {
                          notifier.applyPaymentChanged();
                        }
                      },
                    ),
                    _modernActionButton(
                      context,
                      text: 'Totals',
                      icon: Icons.bar_chart_rounded,
                      onTap: () {
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
                      },
                    ),
                    _modernActionButton(
                      context,
                      text: _exporting ? 'Exporting' : 'Export',
                      icon: Icons.file_download_rounded,
                      onTap: () async {
                        setState(() {
                          _exporting = true;
                        });

                        final snack = await ExcelExportService.export(
                          trip,
                          summary.tripUserMap,
                        );

                        setState(() {
                          _exporting = false;
                        });

                        if (!mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(snack);
                      },
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  10,
                  0,
                  10,
                  120,
                ),
                itemCount: transactions.length + (isRefreshing ? 1 : 0),
                itemBuilder: (_, index) {
                  if (isRefreshing && index == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: LinearProgressIndicator(
                        color: colorScheme.primary,
                        backgroundColor: Colors.transparent,
                      ),
                    );
                  }

                  if (transactions.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 100,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_rounded,
                            size: 70,
                            color: colorScheme.primary.withOpacity(
                              0.32,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'No expenses yet',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by adding an expense or payment',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(
                                0.62,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final idx = isRefreshing ? index - 1 : index;

                  if (idx < 0 || idx >= transactions.length) {
                    return const SizedBox();
                  }

                  final txn = transactions[idx];

                  if (txn.isMonth) {
                    return Padding(
                      padding: const EdgeInsets.only(
                        top: 14,
                        bottom: 10,
                      ),
                      child: Text(
                        txn.month,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyMedium?.color?.withOpacity(
                            0.62,
                          ),
                        ),
                      ),
                    );
                  }

                  return txn.isExpense
                      ? _modernExpenseTile(
                          context,
                          txn,
                          trip,
                          summary,
                          notifier,
                        )
                      : _modernPaymentTile(
                          context,
                          txn,
                          summary,
                          notifier,
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =====================
  // HELPERS
  // =====================

  List<Transaction> _buildTransactions(
    TripModel trip,
  ) {
    final temp = [
      ...trip.expenses.map(
        (e) => Transaction(
          true,
          e.created,
          e,
          null,
        ),
      ),
      ...trip.payments.map(
        (p) => Transaction(
          false,
          p.created,
          null,
          p,
        ),
      ),
    ]..sort(
        (a, b) => b.date.compareTo(
          a.date,
        ),
      );

    final result = <Transaction>[];

    for (int i = 0; i < temp.length; i++) {
      final cur = temp[i];

      final label = '${_months[cur.date.month - 1]} ${cur.date.year}';

      if (i == 0 ||
          cur.date.month != temp[i - 1].date.month ||
          cur.date.year != temp[i - 1].date.year) {
        result.add(
          Transaction(
            false,
            cur.date,
            null,
            null,
            isMonth: true,
            month: label,
          ),
        );
      }

      result.add(cur);
    }

    return result;
  }

  Widget _topActionButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(
            0.78,
          ),
          borderRadius: BorderRadius.circular(
            16,
          ),
          border: Border.all(
            color: colorScheme.primary.withOpacity(
              0.08,
            ),
          ),
        ),
        child: Icon(
          icon,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _modernActionButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(
        right: 12,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary : colorScheme.surface,
            borderRadius: BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color: selected
                  ? Colors.transparent
                  : colorScheme.primary.withOpacity(
                      0.08,
                    ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
              ),
              const SizedBox(width: 10),
              Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? colorScheme.onPrimary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernPaymentTile(
    BuildContext context,
    Transaction txn,
    TripSummary summary,
    TripNotifier notifier,
  ) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

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

        if (!mounted) {
          return;
        }

        if (res == true) {
          notifier.applyPaymentChanged();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.all(
          10,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(
            0.92,
          ),
          borderRadius: BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: colorScheme.primary.withOpacity(
              0.10,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(
                0.08,
              ),
              blurRadius: 26,
              spreadRadius: -8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Text(
                    txn.date.day.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _months[txn.date.month - 1],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(
                        0.58,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const CategoryIcon(
              category: 'payment',
              entityType: 'payment',
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$byName paid $toName',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  // height: 1.4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '₹${payment.amount.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modernExpenseTile(
    BuildContext context,
    Transaction txn,
    TripModel trip,
    TripSummary summary,
    TripNotifier notifier,
  ) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final expense = txn.expense!;

    double paidByMe = 0;

    double paidForMe = 0;

    for (final x in expense.paidBy) {
      if (x.user == summary.currentTripUser) {
        paidByMe += x.amount;
      }
    }

    for (final x in expense.paidFor) {
      if (x.user == summary.currentTripUser) {
        paidForMe += x.amount;
      }
    }

    String involved = '';

    String amount = '';

    Color textColor = colorScheme.onSurface;

    if (paidByMe == 0 && paidForMe == 0) {
      involved = 'not involved';
    } else if (paidByMe >= paidForMe) {
      involved = 'you owed';

      textColor = colorScheme.primary;

      amount = (paidByMe - paidForMe).toStringAsFixed(
        2,
      );
    } else {
      involved = 'you borrowed';

      textColor = AppColors.amber;

      amount = (paidForMe - paidByMe).toStringAsFixed(
        2,
      );
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

        if (!mounted || res == null || res['changed'] != true) {
          return;
        }

        if (res['expense'] == null) {
          notifier.applyExpenseDeleted(
            expense.id,
          );
        } else {
          notifier.applyExpenseUpdated(
            res['expense'] as ExpenseModel,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(
          bottom: 10,
        ),
        padding: const EdgeInsets.all(
          10,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(
            0.92,
          ),
          borderRadius: BorderRadius.circular(
            20,
          ),
          border: Border.all(
            color: textColor.withOpacity(
              0.10,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: textColor.withOpacity(
                0.08,
              ),
              blurRadius: 26,
              spreadRadius: -8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  Text(
                    txn.date.day.toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    _months[txn.date.month - 1],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(
                        0.58,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            CategoryIcon(
              category: expense.category,
              entityType: 'expense',
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    involved,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              amount.isEmpty ? '-' : '₹$amount',
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
