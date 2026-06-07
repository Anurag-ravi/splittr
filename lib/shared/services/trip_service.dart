import 'package:flutter/material.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

abstract final class TripService {
  /// Fetches a single trip by ID, caches it in Hive, and returns it.
  static Future<TripModel?> fetchAndCacheTrip(
    String tripId,
    BuildContext context,
  ) async {
    final data = await AppHttpClient.get(context, '/trip/$tripId');
    if (data == null || data['status'] != 200) return null;
    final trip = TripModel.fromJson(data['data'] as Map<String, dynamic>);
    await HiveBoxes.trips.put(tripId, trip);
    return trip;
  }

  /// Fetches all trips, reconciles Hive (adds new, removes stale), and returns the full list.
  static Future<List<TripModel>?> fetchAndCacheAllTrips(
    BuildContext context,
  ) async {
    final data = await AppHttpClient.get(context, '/trip/');
    if (data == null || data['status'] != 200) return null;

    final tripsList = data['data'] as List;
    final shorts = tripsList.map((e) => ShortTripModel.fromJson(e as Map<String, dynamic>)).toList();
    final full = tripsList.map((e) => TripModel.fromJson(e as Map<String, dynamic>)).toList();

    final shortBox = HiveBoxes.shortTrips;
    final tripBox = HiveBoxes.trips;

    for (final local in shortBox.values.toList()) {
      if (!shorts.any((s) => s.id == local.id)) {
        await shortBox.delete(local.id);
      }
    }
    for (final local in tripBox.values.toList()) {
      if (!full.any((t) => t.id == local.id)) {
        await tripBox.delete(local.id);
      }
    }
    for (final s in shorts) {
      await shortBox.put(s.id, s);
    }
    for (final t in full) {
      await tripBox.put(t.id, t);
    }

    return full;
  }
}
