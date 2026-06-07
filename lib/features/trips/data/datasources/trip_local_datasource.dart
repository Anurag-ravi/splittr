import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';

abstract interface class ITripLocalDatasource {
  Future<void> cacheTrip(TripModel trip);
  Future<void> cacheAllTrips(List<TripModel> trips);
  TripModel? getCachedTrip(String tripId);
  List<ShortTripModel> getCachedShortTrips();
}

class TripLocalDatasource implements ITripLocalDatasource {
  const TripLocalDatasource();

  @override
  Future<void> cacheTrip(TripModel trip) async {
    await HiveBoxes.shortTrips.put(trip.id, ShortTripModel(id: trip.id, name: trip.name));
    await HiveBoxes.trips.put(trip.id, trip);
  }

  @override
  Future<void> cacheAllTrips(List<TripModel> trips) async {
    final shortBox = HiveBoxes.shortTrips;
    final tripBox = HiveBoxes.trips;
    final ids = trips.map((t) => t.id).toSet();

    for (final s in shortBox.values.toList()) {
      if (!ids.contains(s.id)) await shortBox.delete(s.id);
    }
    for (final t in tripBox.values.toList()) {
      if (!ids.contains(t.id)) await tripBox.delete(t.id);
    }
    for (final t in trips) {
      await shortBox.put(t.id, ShortTripModel(id: t.id, name: t.name));
      await tripBox.put(t.id, t);
    }
  }

  @override
  TripModel? getCachedTrip(String tripId) => HiveBoxes.trips.get(tripId);

  @override
  List<ShortTripModel> getCachedShortTrips() =>
      HiveBoxes.shortTrips.values.toList();
}
