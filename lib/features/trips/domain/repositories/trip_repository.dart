import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/trips/domain/entities/trip_entity.dart';
import 'package:splittr/features/trips/domain/entities/trip_member_entity.dart';

abstract interface class ITripRepository {
  Future<Result<TripEntity>> fetchTrip(String tripId);
  Future<Result<List<TripEntity>>> fetchAllTrips();
  Future<Result<void>> createTrip(String name);
  Future<Result<void>> joinTrip(String code);
  Future<Result<void>> editTripName(String tripId, String name);
  Future<Result<void>> leaveTrip(String tripId);
  Future<Result<void>> deleteTrip(String tripId);
  Future<Result<List<TripMemberEntity>>> addMembers(String tripId, List<String> userIds);
  Future<Result<List<TripMemberEntity>>> addNewContact(String tripId, {required String name, required String email});
  Future<Result<List<TripMemberEntity>>> removeMembers(String tripId, List<String> tripUserIds);
  TripEntity? getCachedTrip(String tripId);
  List<ShortTripEntity> getCachedShortTrips();
}
