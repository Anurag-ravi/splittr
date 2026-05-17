import 'package:splittr/core/errors/exceptions.dart';
import 'package:splittr/core/network/api_client.dart';
import 'package:splittr/features/activity/data/models/activity_model.dart';

abstract interface class IActivityRemoteDatasource {
  Future<({List<ActivityModel> items, int total})> fetchPage({
    required int offset, required int limit,
  });
  Future<void> markRead(String activityId);
}

class ActivityRemoteDatasource implements IActivityRemoteDatasource {
  const ActivityRemoteDatasource(this._client);
  final ApiClient _client;

  @override
  Future<({List<ActivityModel> items, int total})> fetchPage({
    required int offset, required int limit,
  }) async {
    final data = await _client.get('/activity/?offset=$offset&limit=$limit');
    if (data['status'] != 200) {
      throw ServerException(data['message']?.toString() ?? 'Server error');
    }
    final items = (data['data'] as List)
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final total = int.tryParse(
            data['pagination']['total'].toString()) ?? 0;
    return (items: items, total: total);
  }

  @override
  Future<void> markRead(String activityId) async {
    await _client.post('/activity/$activityId/read', {});
  }
}
