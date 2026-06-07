import 'package:flutter/material.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/features/activity/data/models/activity_model.dart';

class ActivityRepository {
  const ActivityRepository();

  Future<({List<ActivityModel> items, int total})?> fetchPage(
    BuildContext context, {
    required int offset,
    required int limit,
  }) async {
    final data = await AppHttpClient.get(
        context, '/activity/?offset=$offset&limit=$limit');
    if (data == null || data['status'] != 200) return null;
    final items = (data['data'] as List)
        .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final total =
        int.tryParse(data['pagination']['total'].toString()) ?? 0;
    return (items: items, total: total);
  }

  Future<void> markRead(BuildContext context, String activityId) =>
      AppHttpClient.post(context, '/activity/$activityId/read', {});
}
