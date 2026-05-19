import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/widgets/app_loader.dart';
import 'package:splittr/core/widgets/profile_image.dart';
import 'package:splittr/features/friends/domain/entities/friend_entity.dart';
import 'package:splittr/features/friends/presentation/providers/friends_providers.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

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
      ref.read(friendsNotifierProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final friendsAsync = ref.watch(friendsNotifierProvider);

    final friends = friendsAsync.value ?? [];

    final isLoading = friendsAsync.isLoading && !(friendsAsync.hasValue);

    final isSyncing = friendsAsync.isLoading && friendsAsync.hasValue;

    if (isLoading && friends.isEmpty) {
      return const AppLoader();
    }

    if (friends.isEmpty && !isSyncing) {
      return _EmptyState();
    }

    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: () async {
        await ref.read(friendsNotifierProvider.notifier).initialize();
      },
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (isSyncing)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: colorScheme.primary.withOpacity(0.08),
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              6,
              16,
              110,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final friend = friends[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _FriendTile(friend: friend),
                  );
                },
                childCount: friends.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({
    required this.friend,
  });

  final FriendEntity friend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return NeonGlow(
      color: colorScheme.primary,
      radius: 18,
      spread: -6,
      glowOpacity: 0.08,
      child: Container(
        height: 96,
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(
            theme.brightness == Brightness.dark ? 0.88 : 0.96,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: colorScheme.primary.withOpacity(
              theme.brightness == Brightness.dark ? 0.10 : 0.06,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                theme.brightness == Brightness.dark ? 0.16 : 0.04,
              ),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          child: Row(
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.transparent,
                ),
                child: ClipOval(
                  child: ProfileImage(id: friend.name),
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      friend.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      friend.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.68),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${friend.countryCode} ${friend.phone}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color:
                            theme.textTheme.bodySmall?.color?.withOpacity(0.58),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            NeonGlow(
              color: colorScheme.primary,
              radius: 50,
              spread: 2,
              glowOpacity: 0.16,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.16),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.people_alt_rounded,
                  size: 64,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'No Friends Yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Friends you add or split expenses with will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.7,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
