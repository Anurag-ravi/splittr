import 'package:splittr/core/errors/exceptions.dart';
import 'package:splittr/core/network/api_client.dart';
import 'package:splittr/features/trips/data/models/trip_model.dart';
import 'package:splittr/features/trips/data/models/trip_member_model.dart';

abstract interface class ITripRemoteDatasource {
  Future<TripModel> fetchTrip(String tripId);
  Future<List<TripModel>> fetchAllTrips();
  Future<void> createTrip(String name);
  Future<void> joinTrip(String code);
  Future<void> editTripName(String tripId, String name);
  Future<void> leaveTrip(String tripId);
  Future<void> deleteTrip(String tripId);
  Future<List<TripMemberModel>> addMembers(String tripId, List<String> userIds);
  Future<List<TripMemberModel>> addNewContact(String tripId, {required String name, required String email});
  Future<List<TripMemberModel>> removeMembers(String tripId, List<String> tripUserIds);
}

class TripRemoteDatasource implements ITripRemoteDatasource {
  const TripRemoteDatasource(this._client);
  final ApiClient _client;

  @override
  Future<TripModel> fetchTrip(String tripId) async {
    final data = await _client.get('/trip/$tripId');
    _check(data);
    return TripModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<TripModel>> fetchAllTrips() async {
    final data = await _client.get('/trip/');
    _check(data);
    return (data['data'] as List)
        .map((e) => TripModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> createTrip(String name) async {
    final data = await _client.post('/trip/new', {'name': name});
    _check(data);
  }

  @override
  Future<void> joinTrip(String code) async {
    final data = await _client.post('/trip/join', {'code': code});
    _check(data);
  }

  @override
  Future<void> editTripName(String tripId, String name) async {
    final data = await _client.post('/trip/$tripId/edit', {'name': name});
    _check(data);
  }

  @override
  Future<void> leaveTrip(String tripId) async {
    final data = await _client.get('/trip/$tripId/leave');
    _check(data);
  }

  @override
  Future<void> deleteTrip(String tripId) async {
    final data = await _client.delete('/trip/$tripId');
    _check(data);
  }

  @override
  Future<List<TripMemberModel>> addMembers(
      String tripId, List<String> userIds) async {
    final data = await _client
        .post('/trip/$tripId/add-many', {'users': userIds});
    _check(data);
    return (data['data'] as List)
        .map((e) => TripMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TripMemberModel>> addNewContact(String tripId,
      {required String name, required String email}) async {
    final data = await _client
        .post('/trip/$tripId/add-new', {'name': name, 'email': email});
    _check(data);
    return (data['data'] as List)
        .map((e) => TripMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<TripMemberModel>> removeMembers(
      String tripId, List<String> tripUserIds) async {
    final data = await _client
        .post('/trip/$tripId/leave-many', {'users': tripUserIds});
    _check(data);
    return (data['data'] as List)
        .map((e) => TripMemberModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  void _check(Map<String, dynamic> data) {
    if (data['status'] != 200) {
      throw ServerException(data['message']?.toString() ?? 'Server error');
    }
  }
}
