import 'package:flutter/material.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

class TripRepository {
  const TripRepository();

  Future<TripModel?> fetchAndCacheTrip(
      BuildContext context, String tripId) async {
    final data = await AppHttpClient.get(context, '/trip/$tripId');
    if (data == null || data['status'] != 200) return null;
    final trip = TripModel.fromJson(data['data'] as Map<String, dynamic>);
    await HiveBoxes.trips.put(tripId, trip);
    return trip;
  }

  Future<List<TripModel>?> fetchAndCacheAllTrips(BuildContext context) async {
    final data = await AppHttpClient.get(context, '/trip/');
    if (data == null || data['status'] != 200) return null;

    final tripsList = data['data'] as List;
    final shorts = tripsList
        .map((e) => ShortTripModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final full = tripsList
        .map((e) => TripModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final shortBox = HiveBoxes.shortTrips;
    final tripBox = HiveBoxes.trips;

    for (final local in shortBox.values.toList()) {
      if (!shorts.any((s) => s.id == local.id)) await shortBox.delete(local.id);
    }
    for (final local in tripBox.values.toList()) {
      if (!full.any((t) => t.id == local.id)) await tripBox.delete(local.id);
    }
    for (final s in shorts) await shortBox.put(s.id, s);
    for (final t in full) await tripBox.put(t.id, t);

    return full;
  }

  Future<Map<String, dynamic>?> createTrip(
          BuildContext context, String name) =>
      AppHttpClient.post(context, '/trip/new', {'name': name});

  Future<Map<String, dynamic>?> joinTrip(
          BuildContext context, String code) =>
      AppHttpClient.post(context, '/trip/join', {'code': code});

  Future<Map<String, dynamic>?> editTripName(
          BuildContext context, String tripId, String name) =>
      AppHttpClient.post(context, '/trip/$tripId/edit', {'name': name});

  Future<Map<String, dynamic>?> leaveTrip(
          BuildContext context, String tripId) =>
      AppHttpClient.get(context, '/trip/$tripId/leave');

  Future<Map<String, dynamic>?> deleteTrip(
          BuildContext context, String tripId) =>
      AppHttpClient.delete(context, '/trip/$tripId');

  TripModel? getCachedTrip(String tripId) => HiveBoxes.trips.get(tripId);

  List<TripModel> cachedTrips() => HiveBoxes.trips.values.toList();

  List<ShortTripModel> cachedShortTrips() => HiveBoxes.shortTrips.values.toList();
}
