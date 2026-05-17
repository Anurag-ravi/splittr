import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/trips/domain/entities/trip_entity.dart';
import 'package:splittr/features/trips/domain/repositories/trip_repository.dart';

class FetchAllTripsUseCase {
  const FetchAllTripsUseCase(this._repo);
  final ITripRepository _repo;

  Future<Result<List<TripEntity>>> call() => _repo.fetchAllTrips();
}

class FetchTripUseCase {
  const FetchTripUseCase(this._repo);
  final ITripRepository _repo;

  Future<Result<TripEntity>> call(String tripId) => _repo.fetchTrip(tripId);
}
