import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/friends/domain/entities/friend_entity.dart';
import 'package:splittr/features/friends/domain/repositories/friends_repository.dart';

class FetchFriendsUseCase {
  const FetchFriendsUseCase(this._repo);
  final IFriendsRepository _repo;

  Future<Result<List<FriendEntity>>> call(List<String> contactNumbers) =>
      _repo.fetchFriends(contactNumbers);
}
