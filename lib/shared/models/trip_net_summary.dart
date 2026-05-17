import 'package:flutter/material.dart';

class TripNetSummary {
  final String message;
  final Color color;
  final double amount;
  final bool settled;

  const TripNetSummary({
    required this.message,
    required this.color,
    required this.amount,
    required this.settled,
  });
}
