import 'package:flutter/material.dart';
import 'package:splittr/core/constants/expense_categories.dart';
import 'package:splittr/core/utils/haptics.dart';

class ChooseCategoryScreen extends StatelessWidget {
  const ChooseCategoryScreen({super.key, required this.current});

  final String current;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Choose category', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, current),
        ),
      ),
      body: ListView.builder(
        itemCount: ExpenseCategories.all.length,
        itemBuilder: (context, index) {
          final cat = ExpenseCategories.all[index];
          return GestureDetector(
            onTap: () {
              Haptics.medium();
              Navigator.pop(context, cat);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      'assets/categories/$cat.png',
                      height: 45,
                      width: 45,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    ExpenseCategories.labelOf(cat),
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
