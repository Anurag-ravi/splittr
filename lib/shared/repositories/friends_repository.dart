import 'package:flutter/material.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/auth/data/models/user_model.dart';

class FriendsRepository {
  const FriendsRepository();

  Future<List<UserModel>?> fetchFriends(
      BuildContext context, List<String> numbers) async {
    final data = await AppHttpClient.post(
        context, '/auth/get-friends', {'contacts': numbers});
    if (data == null || data['status'] != 200) return null;
    final fetched = (data['friends'] as List)
        .map((u) => UserModel.fromJson(u as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    await _sync(fetched);
    return fetched;
  }

  Future<void> _sync(List<UserModel> fetched) async {
    final box = HiveBoxes.users;
    final ids = fetched.map((u) => u.id).toSet();
    for (final u in box.values.toList()) {
      if (!ids.contains(u.id)) await box.delete(u.id);
    }
    for (final u in fetched) {
      await box.put(u.id, u);
    }
  }

  List<UserModel> cachedFriends() {
    return HiveBoxes.users.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
}
