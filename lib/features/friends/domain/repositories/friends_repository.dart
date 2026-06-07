import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/friends/domain/entities/friend_entity.dart';

abstract interface class IFriendsRepository {
  Future<Result<List<FriendEntity>>> fetchFriends(List<String> contactNumbers);
  List<FriendEntity> getCachedFriends();
}
