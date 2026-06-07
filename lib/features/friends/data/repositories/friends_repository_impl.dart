import 'package:splittr/core/errors/exceptions.dart';
import 'package:splittr/core/errors/failures.dart';
import 'package:splittr/core/errors/result.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/auth/data/models/user_model.dart';
import 'package:splittr/features/friends/data/datasources/friends_remote_datasource.dart';
import 'package:splittr/features/friends/data/models/friend_model.dart';
import 'package:splittr/features/friends/domain/entities/friend_entity.dart';
import 'package:splittr/features/friends/domain/repositories/friends_repository.dart';

class FriendsRepositoryImpl implements IFriendsRepository {
  const FriendsRepositoryImpl(this._remote);
  final IFriendsRemoteDatasource _remote;

  @override
  Future<Result<List<FriendEntity>>> fetchFriends(
      List<String> contactNumbers) async {
    try {
      final models = await _remote.fetchFriends(contactNumbers);
      await _syncCache(models);
      return ok(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  List<FriendEntity> getCachedFriends() {
    return HiveBoxes.users.values
        .map((u) => FriendEntity(
              id: u.id,
              name: u.name,
              email: u.email,
              countryCode: u.countryCode,
              phone: u.phone,
              dp: u.dp,
            ))
        .toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  Future<void> _syncCache(List<FriendModel> fetched) async {
    final box = HiveBoxes.users;
    final ids = fetched.map((f) => f.id).toSet();
    for (final u in box.values.toList()) {
      if (!ids.contains(u.id)) await box.delete(u.id);
    }
    for (final f in fetched) {
      await box.put(
        f.id,
        UserModel(
          id: f.id,
          name: f.name,
          email: f.email,
          countryCode: f.countryCode,
          phone: f.phone,
          upiId: '',
          dp: f.dp,
        ),
      );
    }
  }
}
