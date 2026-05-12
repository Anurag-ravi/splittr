import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/models/trip.dart';
import 'package:splittr/utilities/boxes.dart';
import 'package:splittr/utilities/request.dart';

class TripService {
  /// Fetches a single trip by ID from the API, caches it in Hive, and returns it.
  /// Returns null if the request fails or the context is no longer mounted.
  static Future<TripModel?> fetchAndCacheTrip(
      String tripId, SharedPreferences prefs, BuildContext context) async {
    final url = prefs.getString('url');
    final token = prefs.getString('token');
    if (url == null || token == null) return null;

    final data = await getRequest(
      '$url/trip/$tripId',
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      prefs,
      context,
    );

    if (data != null && data['status'] == 200) {
      final trip = TripModel.fromJson(data['data']);
      await Boxes.getTrips().put(tripId, trip);
      return trip;
    }
    return null;
  }

  /// Fetches all trips from the API, reconciles the Hive boxes (adds new,
  /// removes stale entries for both ShortTripModel and TripModel), and returns
  /// the full list. Returns null if the request fails.
  static Future<List<TripModel>?> fetchAndCacheAllTrips(
      SharedPreferences prefs, BuildContext context) async {
    final url = prefs.getString('url');
    final token = prefs.getString('token');
    if (url == null || token == null) return null;

    final data = await getRequest(
      '$url/trip/',
      {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token,
      },
      prefs,
      context,
    );

    if (data == null || data['status'] != 200) return null;

    final tripsList = data['data'] as List;
    final List<ShortTripModel> shorts =
        tripsList.map((e) => ShortTripModel.fromJson(e)).toList();
    final List<TripModel> full =
        tripsList.map((e) => TripModel.fromJson(e)).toList();

    final shortTripBox = Boxes.getShortTrips();
    final tripBox = Boxes.getTrips();

    // Remove stale short trips
    for (final local in shortTripBox.values.toList()) {
      if (!shorts.any((s) => s.id == local.id)) {
        await shortTripBox.delete(local.id);
      }
    }
    // Remove stale full trips
    for (final local in tripBox.values.toList()) {
      if (!full.any((t) => t.id == local.id)) {
        await tripBox.delete(local.id);
      }
    }
    for (final s in shorts) {
      await shortTripBox.put(s.id, s);
    }
    for (final t in full) {
      await tripBox.put(t.id, t);
    }

    return full;
  }
}
