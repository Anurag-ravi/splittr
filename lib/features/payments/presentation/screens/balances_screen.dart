import 'package:flutter/material.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/payments/presentation/screens/record_payment_screen.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/shared/services/settle_up_service.dart';

class _Bal {
  final String label;
  final String from;
  final String to;
  final double amount;
  final bool isPositive;
  final bool isSettled;
  final bool isMainEntry;

  const _Bal({
    required this.label,
    required this.from,
    required this.to,
    required this.amount,
    required this.isPositive,
    required this.isSettled,
    required this.isMainEntry,
  });
}

class BalancesScreen extends StatefulWidget {
  const BalancesScreen({
    super.key,
    required this.trip,
    required this.tripUserMap,
  });

  final TripModel trip;
  final Map<String, TripMemberModel> tripUserMap;

  @override
  State<BalancesScreen> createState() => _BalancesScreenState();
}

class _BalancesScreenState extends State<BalancesScreen> {
  List<_Bal> _items = [];
  List<bool> _expanded = [];

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    final balances = SettleUpService.balances(widget.trip);
    final items = <_Bal>[];

    for (final b in balances) {
      final tu = widget.tripUserMap[b.user];
      if (tu == null || !tu.involved) continue;

      if (b.amount == 0.0) {
        items.add(_Bal(
          label: '${tu.name} is settled up',
          from: b.user,
          to: '',
          amount: 0,
          isPositive: true,
          isSettled: true,
          isMainEntry: true,
        ));
      } else {
        items.add(_Bal(
          label: '${tu.name} ${b.isPositive ? 'gets back' : 'owes'}',
          from: b.user,
          to: '',
          amount: b.amount,
          isPositive: b.isPositive,
          isSettled: false,
          isMainEntry: true,
        ));
        for (final entry in b.paid) {
          final from = b.isPositive ? entry.user : b.user;
          final to = b.isPositive ? b.user : entry.user;
          items.add(_Bal(
            label: '${widget.tripUserMap[from]?.name ?? ''} owes ',
            from: from,
            to: to,
            amount: entry.amount,
            isPositive: b.isPositive,
            isSettled: false,
            isMainEntry: false,
          ));
        }
      }
    }

    setState(() {
      _items = items;
      _expanded = List.filled(items.length, false);
    });
  }

  void _toggleSection(int index) {
    Haptics.medium();
    setState(() {
      int i = index;
      _expanded[i] = !_expanded[i];
      i++;
      while (i < _items.length && !_items[i].isMainEntry) {
        _expanded[i] = _expanded[index];
        i++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Balances', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.grey[850],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (_, index) {
          final item = _items[index];
          if (item.isMainEntry) {
            return GestureDetector(
              onTap: () => _toggleSection(index),
              child: Container(
                padding: const EdgeInsets.only(left: 10, top: 25),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                              'assets/profile/${widget.tripUserMap[item.from]!.dp}.png'),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 12,
                      child: RichText(
                        overflow: TextOverflow.clip,
                        text: TextSpan(children: [
                          TextSpan(
                            text: item.label,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 17),
                          ),
                          if (!item.isSettled) ...[
                            TextSpan(
                              text: ' ₹${item.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: item.isPositive
                                    ? AppColors.primary
                                    : AppColors.amber,
                                fontSize: 17,
                              ),
                            ),
                            const TextSpan(
                              text: ' in total',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17),
                            ),
                          ],
                        ]),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: item.isSettled
                          ? const Icon(Icons.check_circle,
                              color: AppColors.primary, size: 17)
                          : Icon(
                              _expanded[index]
                                  ? Icons.keyboard_arrow_up_outlined
                                  : Icons.keyboard_arrow_down_outlined,
                              color: Colors.white,
                              size: 25,
                            ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (!_expanded[index]) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.only(left: 50, top: 10),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                            'assets/profile/${widget.tripUserMap[item.from]!.dp}.png'),
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: RichText(
                        overflow: TextOverflow.clip,
                        text: TextSpan(children: [
                          TextSpan(
                            text: item.label,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                          TextSpan(
                            text: '₹${item.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: item.isPositive
                                  ? AppColors.primary
                                  : AppColors.amber,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text:
                                ' to ${widget.tripUserMap[item.to]?.name ?? ''}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        ]),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const SizedBox(width: 50),
                    GestureDetector(
                      onTap: () async {
                        Haptics.medium();
                        final res = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecordPaymentScreen(
                              tripUserMap: widget.tripUserMap,
                              from: item.from,
                              to: item.to,
                              amount: item.amount,
                            ),
                          ),
                        );
                        if (!mounted) return;
                        if (res == true) Navigator.pop(context, true);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        height: 30,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: AppColors.primary, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text('Settle up',
                            style: TextStyle(
                                color: AppColors.primary, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
