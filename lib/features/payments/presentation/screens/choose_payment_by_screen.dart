import 'package:flutter/material.dart';
import 'package:splittr/core/utils/haptics.dart';
import 'package:splittr/features/payments/presentation/screens/choose_payment_for_screen.dart';
import 'package:splittr/features/expenses/data/models/expense_model.dart';
import 'package:splittr/features/payments/data/models/payment_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class ChoosePaymentByScreen extends StatelessWidget {
  const ChoosePaymentByScreen({super.key, required this.tripUserMap});

  final Map<String, TripMemberModel> tripUserMap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Payment From?',
            style: TextStyle(color: Colors.white, fontSize: 18)),
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView.builder(
        itemCount: tripUserMap.length,
        itemBuilder: (context, index) {
          final user = tripUserMap.values.elementAt(index);
          if (!user.involved) return const SizedBox.shrink();
          return GestureDetector(
            onTap: () async {
              Haptics.medium();
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChoosePaymentForScreen(
                    tripUserMap: tripUserMap,
                    from: user.id,
                  ),
                ),
              );
              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/profile/${user.dp}.png',
                      height: 40,
                      width: 40,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(user.name,
                      style: const TextStyle(color: Colors.white)),
                  const Spacer(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
