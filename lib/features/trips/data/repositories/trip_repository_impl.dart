import 'package:splittr/core/errors/exceptions.dart';
import 'package:splittr/core/errors/failures.dart';
import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/trips/data/datasources/trip_local_datasource.dart';
import 'package:splittr/features/trips/data/datasources/trip_remote_datasource.dart';
import 'package:splittr/features/trips/domain/entities/trip_entity.dart';
import 'package:splittr/features/trips/domain/entities/trip_member_entity.dart';
import 'package:splittr/features/trips/domain/repositories/trip_repository.dart';

class TripRepositoryImpl implements ITripRepository {
  const TripRepositoryImpl({
    required ITripRemoteDatasource remote,
    required ITripLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  final ITripRemoteDatasource _remote;
  final ITripLocalDatasource _local;

  @override
  Future<Result<TripEntity>> fetchTrip(String tripId) async {
    try {
      final model = await _remote.fetchTrip(tripId);
      await _local.cacheTrip(model);
      return ok(model.toEntity());
    } on UnauthorizedException {
      return err(const UnauthorizedFailure());
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<TripEntity>>> fetchAllTrips() async {
    try {
      final models = await _remote.fetchAllTrips();
      await _local.cacheAllTrips(models);
      return ok(models.map((m) => m.toEntity()).toList());
    } on UnauthorizedException {
      return err(const UnauthorizedFailure());
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> createTrip(String name) =>
      _wrap(() => _remote.createTrip(name));

  @override
  Future<Result<void>> joinTrip(String code) =>
      _wrap(() => _remote.joinTrip(code));

  @override
  Future<Result<void>> editTripName(String tripId, String name) =>
      _wrap(() => _remote.editTripName(tripId, name));

  @override
  Future<Result<void>> leaveTrip(String tripId) =>
      _wrap(() => _remote.leaveTrip(tripId));

  @override
  Future<Result<void>> deleteTrip(String tripId) =>
      _wrap(() => _remote.deleteTrip(tripId));

  @override
  Future<Result<List<TripMemberEntity>>> addMembers(
      String tripId, List<String> userIds) async {
    try {
      final members = await _remote.addMembers(tripId, userIds);
      return ok(members.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<TripMemberEntity>>> addNewContact(String tripId,
      {required String name, required String email}) async {
    try {
      final members = await _remote.addNewContact(tripId, name: name, email: email);
      return ok(members.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<TripMemberEntity>>> removeMembers(
      String tripId, List<String> tripUserIds) async {
    try {
      final members = await _remote.removeMembers(tripId, tripUserIds);
      return ok(members.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  TripEntity? getCachedTrip(String tripId) =>
      _local.getCachedTrip(tripId)?.toEntity();

  @override
  List<ShortTripEntity> getCachedShortTrips() =>
      _local.getCachedShortTrips().map((s) => s.toEntity()).toList();

  Future<Result<void>> _wrap(Future<void> Function() call) async {
    try {
      await call();
      return ok(null);
    } on UnauthorizedException {
      return err(const UnauthorizedFailure());
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }
}
