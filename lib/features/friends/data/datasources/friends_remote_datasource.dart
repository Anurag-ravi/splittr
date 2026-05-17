import 'package:splittr/core/errors/exceptions.dart';
import 'package:splittr/core/network/api_client.dart';
import 'package:splittr/features/friends/data/models/friend_model.dart';

abstract interface class IFriendsRemoteDatasource {
  Future<List<FriendModel>> fetchFriends(List<String> contactNumbers);
}

class FriendsRemoteDatasource implements IFriendsRemoteDatasource {
  const FriendsRemoteDatasource(this._client);
  final ApiClient _client;

  @override
  Future<List<FriendModel>> fetchFriends(List<String> contactNumbers) async {
    final data = await _client
        .post('/auth/get-friends', {'contacts': contactNumbers});
    if (data['status'] != 200) {
      throw ServerException(data['message']?.toString() ?? 'Server error');
    }
    return (data['friends'] as List)
        .map((u) => FriendModel.fromJson(u as Map<String, dynamic>))
        .toList();
  }
}
