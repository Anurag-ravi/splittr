import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/widgets/app_loader.dart';
import 'package:splittr/features/friends/presentation/providers/friends_providers.dart';
import 'package:splittr/features/friends/domain/entities/friend_entity.dart';

class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(friendsNotifierProvider.notifier)
          .initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final friendsAsync = ref.watch(friendsNotifierProvider);
    final friends = friendsAsync.value ?? [];
    final isLoading = friendsAsync.isLoading && !(friendsAsync.hasValue);
    final isSyncing = friendsAsync.isLoading && friendsAsync.hasValue;

    if (isLoading && friends.isEmpty) return const AppLoader();

    if (friends.isEmpty && !isSyncing) {
      return const Center(
          child: Text('No friends found',
              style: TextStyle(color: Colors.grey)));
    }

    return ListView.builder(
      itemCount: friends.length + (isSyncing ? 1 : 0),
      itemBuilder: (_, index) {
        if (isSyncing && index == 0) {
          return const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            color: Color(0xff1dc29f),
          );
        }
        final friend = friends[isSyncing ? index - 1 : index];
        return _FriendTile(friend: friend);
      },
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({required this.friend});

  final FriendEntity friend;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[800],
        ),
        child: Row(
          children: [
            ClipOval(
              child: SizedBox(
                width: 50,
                height: 50,
                child: Image.asset(
                    'assets/profile/${friend.dp}.png',
                    fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(friend.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 15)),
                  Text(friend.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11)),
                  Text('${friend.countryCode} ${friend.phone}',
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
