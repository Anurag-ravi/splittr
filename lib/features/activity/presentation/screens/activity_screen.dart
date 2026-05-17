import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/theme/app_colors.dart';
import 'package:splittr/core/utils/date_formatter.dart';
import 'package:splittr/features/activity/presentation/providers/activity_providers.dart';
import 'package:splittr/features/activity/presentation/states/activity_state.dart';
import 'package:splittr/features/activity/presentation/widgets/activity_icon.dart';
import 'package:splittr/features/activity/domain/entities/activity_entity.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(activityNotifierProvider.notifier).refresh();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(activityNotifierProvider.notifier).loadMore();
    }
  }

  Color _subtitleColor(String? net) {
    switch (net) {
      case '+':
        return AppColors.primary;
      case '-':
        return AppColors.secondary;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activityAsync = ref.watch(activityNotifierProvider);
    final notifier = ref.read(activityNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: activityAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary)),
        error: (e, _) => Center(
            child: Text(e.toString(),
                style: const TextStyle(color: Colors.white54))),
        data: (feed) {
          if (feed == null) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          final items = feed.items;
          final loadingMore = feed.loadingMore;
          final loadingId = feed.loadingId;
          if (items.isEmpty) {
            return const Center(
                child: Text('No activity yet',
                    style: TextStyle(color: Colors.white54)));
          }
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => notifier.refresh(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: items.length + (loadingMore ? 1 : 0),
              itemBuilder: (_, index) {
                if (index == items.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }
                final activity = items[index];
                final isItemLoading = loadingId == activity.id;
                return _ActivityTile(
                  activity: activity,
                  icon: isItemLoading
                      ? const SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary),
                          ),
                        )
                      : ActivityIcon(activity: activity),
                  subtitleColor: _subtitleColor(activity.net),
                  dateText: DateFormatter.shortDate(activity.createdAt),
                  onTap: loadingId != null
                      ? null
                      : () => notifier.tapActivity(context, activity),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.activity,
    required this.icon,
    required this.subtitleColor,
    required this.dateText,
    required this.onTap,
  });

  final ActivityEntity activity;
  final Widget icon;
  final Color subtitleColor;
  final String dateText;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final unread = !activity.read;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: unread ? Colors.grey[800] : Colors.transparent,
          border: unread
              ? const Border(
                  left: BorderSide(color: AppColors.primary, width: 3))
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(activity.title,
                      style:
                          const TextStyle(color: Colors.white, fontSize: 14)),
                  if (activity.subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(activity.subtitle!,
                        style: TextStyle(color: subtitleColor, fontSize: 12)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(dateText,
                style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
