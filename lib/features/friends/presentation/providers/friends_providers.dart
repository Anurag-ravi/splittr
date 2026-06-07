import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/features/friends/domain/entities/friend_entity.dart';
import 'package:splittr/features/friends/presentation/controllers/friends_controller.dart';

final friendsNotifierProvider =
    AsyncNotifierProvider<FriendsNotifier, List<FriendEntity>>(
        FriendsNotifier.new);
