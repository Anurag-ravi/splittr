import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/trips/domain/entities/trip_member_entity.dart';
import 'package:splittr/features/trips/domain/repositories/trip_repository.dart';

class CreateTripUseCase {
  const CreateTripUseCase(this._repo);
  final ITripRepository _repo;
  Future<Result<void>> call(String name) => _repo.createTrip(name);
}

class JoinTripUseCase {
  const JoinTripUseCase(this._repo);
  final ITripRepository _repo;
  Future<Result<void>> call(String code) => _repo.joinTrip(code);
}

class EditTripNameUseCase {
  const EditTripNameUseCase(this._repo);
  final ITripRepository _repo;
  Future<Result<void>> call(String tripId, String name) =>
      _repo.editTripName(tripId, name);
}

class LeaveTripUseCase {
  const LeaveTripUseCase(this._repo);
  final ITripRepository _repo;
  Future<Result<void>> call(String tripId) => _repo.leaveTrip(tripId);
}

class DeleteTripUseCase {
  const DeleteTripUseCase(this._repo);
  final ITripRepository _repo;
  Future<Result<void>> call(String tripId) => _repo.deleteTrip(tripId);
}

class AddMembersUseCase {
  const AddMembersUseCase(this._repo);
  final ITripRepository _repo;
  Future<Result<List<TripMemberEntity>>> call(
          String tripId, List<String> userIds) =>
      _repo.addMembers(tripId, userIds);
}

class RemoveMembersUseCase {
  const RemoveMembersUseCase(this._repo);
  final ITripRepository _repo;
  Future<Result<List<TripMemberEntity>>> call(
          String tripId, List<String> tripUserIds) =>
      _repo.removeMembers(tripId, tripUserIds);
}
