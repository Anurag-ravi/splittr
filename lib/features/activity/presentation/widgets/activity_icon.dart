import 'package:flutter/material.dart';
import 'package:splittr/features/activity/domain/entities/activity_entity.dart';

class ActivityIcon extends StatelessWidget {
  const ActivityIcon({super.key, required this.activity});

  final ActivityEntity activity;

  @override
  Widget build(BuildContext context) {
    if (activity.entityType == 'trip') {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.group, color: Colors.white70, size: 28),
      );
    }

    final asset = activity.entityType == 'payment'
        ? 'payment'
        : (activity.category ?? 'general');

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.asset(
        'assets/categories/$asset.png',
        width: 48,
        height: 48,
        errorBuilder: (_, __, ___) => Container(
          width: 48,
          height: 48,
          color: Colors.grey[700],
          child: const Icon(Icons.receipt, color: Colors.white54),
        ),
      ),
    );
  }
}
