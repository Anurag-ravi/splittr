import 'package:flutter/material.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';

class TripSummary {
  final bool free;
  final bool deletable;

  final String involvedText;
  final Color textColor;

  final double paidByMe;
  final double paidForMe;
  final double total;

  final String currentTripUser;

  final Map<String, TripMemberModel> tripUserMap;

  const TripSummary({
    required this.free,
    required this.deletable,
    required this.involvedText,
    required this.textColor,
    required this.paidByMe,
    required this.paidForMe,
    required this.total,
    required this.currentTripUser,
    required this.tripUserMap,
  });
}
