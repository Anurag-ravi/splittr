import 'package:flutter/material.dart';
import 'package:splittr/core/theme/app_colors.dart';

class TotalsScreen extends StatelessWidget {
  const TotalsScreen({
    super.key,
    required this.name,
    required this.paidByMe,
    required this.paidForMe,
    required this.total,
  });

  final String name;
  final double paidByMe;
  final double paidForMe;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text(name, style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _row('Total group spending', total),
            const SizedBox(height: 20),
            _row('You paid', paidByMe, color: AppColors.primary),
            const SizedBox(height: 20),
            _row('Your share', paidForMe, color: AppColors.amber),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double amount, {Color color = Colors.white}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
        Text('₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
