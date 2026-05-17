import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/shared/models/trip_summary.dart';

/// Immutable snapshot of what the TripScreen needs.
class TripScreenData {
  const TripScreenData({required this.trip, required this.summary});
  final TripModel trip;
  final TripSummary summary;
}
