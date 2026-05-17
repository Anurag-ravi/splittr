import 'package:flutter/material.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/payments/presentation/screens/record_payment_screen.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/shared/services/settle_up_service.dart';

class SettleUpScreen extends StatelessWidget {
  const SettleUpScreen({
    super.key,
    required this.trip,
    required this.tripUserMap,
  });

  final TripModel trip;
  final Map<String, TripMemberModel> tripUserMap;

  @override
  Widget build(BuildContext context) {
    final triads = SettleUpService.triads(trip);

    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Settle Up', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: triads.isEmpty
          ? const Center(
              child: Text('Everyone is settled up!',
                  style: TextStyle(color: Colors.white70)))
          : ListView.builder(
              itemCount: triads.length,
              itemBuilder: (_, i) {
                final t = triads[i];
                final fromUser = tripUserMap[t.from];
                final toUser = tripUserMap[t.to];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'assets/profile/${fromUser?.dp ?? 'default'}.png',
                          width: 48,
                          height: 48,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: '${fromUser?.name ?? ''} owes ',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                            TextSpan(
                              text: '₹${t.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  color: AppColors.amber, fontSize: 14),
                            ),
                            TextSpan(
                              text: ' to ${toUser?.name ?? ''}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            ),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          Haptics.medium();
                          final res = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecordPaymentScreen(
                                tripUserMap: tripUserMap,
                                from: t.from,
                                to: t.to,
                                amount: t.amount,
                              ),
                            ),
                          );
                          if (!context.mounted) return;
                          if (res == true) Navigator.pop(context, true);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: AppColors.primary, width: 1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Text('Settle up',
                              style: TextStyle(
                                  color: AppColors.primary, fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
