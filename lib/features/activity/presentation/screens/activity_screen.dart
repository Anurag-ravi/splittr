import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/utils/date_formatter.dart';
import 'package:splittr/core/widgets/app_loader.dart';
import 'package:splittr/core/widgets/category_icon.dart';
import 'package:splittr/features/activity/domain/entities/activity_entity.dart';
import 'package:splittr/features/activity/presentation/providers/activity_providers.dart';
import 'package:splittr/shared/widgets/neon_glow.dart';

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

  Color _subtitleColor(
    BuildContext context,
    String? net,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (net) {
      case '+':
        return colorScheme.primary;

      case '-':
        return colorScheme.error;

      default:
        return Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6) ??
            Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final activityAsync = ref.watch(activityNotifierProvider);

    final notifier = ref.read(activityNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: activityAsync.when(
        loading: () => const AppLoader(),
        error: (e, _) => Center(
          child: Text(
            e.toString(),
            style: theme.textTheme.bodyLarge,
          ),
        ),
        data: (feed) {
          if (feed == null) {
            return const AppLoader();
          }

          final items = feed.items;

          final loadingMore = feed.loadingMore;

          final loadingId = feed.loadingId;

          if (items.isEmpty) {
            return _EmptyState();
          }

          return RefreshIndicator(
            color: colorScheme.primary,
            onRefresh: () => notifier.refresh(),
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 110,
              ),

              // IMPORTANT
              // no vertical gap between tiles

              itemCount: items.length + (loadingMore ? 1 : 0),
              itemBuilder: (_, index) {
                if (index == items.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  );
                }

                final activity = items[index];

                final isItemLoading = loadingId == activity.id;

                return _ActivityTile(
                  activity: activity,
                  subtitleColor: _subtitleColor(
                    context,
                    activity.net,
                  ),
                  dateText: DateFormatter.shortDate(
                    activity.createdAt,
                  ),
                  onTap: loadingId != null
                      ? null
                      : () => notifier.tapActivity(
                            context,
                            activity,
                          ),
                  icon: isItemLoading
                      ? SizedBox(
                          width: 54,
                          height: 54,
                          child: Center(
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        )
                      : CategoryIcon(
                          category: activity.category,
                          entityType: activity.entityType),
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
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final unread = !activity.read;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: unread
              ? colorScheme.surface.withOpacity(
                  theme.brightness == Brightness.dark ? 0.92 : 1,
                )
              : Colors.transparent,

          // IMPORTANT
          // NO BORDER RADIUS

          border: Border(
            left: BorderSide(
              color: unread ? colorScheme.primary : Colors.transparent,
              width: 3,
            ),
          ),

          boxShadow: unread
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(
                      theme.brightness == Brightness.dark ? 0.08 : 0.03,
                    ),
                    blurRadius: 24,
                    spreadRadius: -6,
                  ),
                ]
              : null,
        ),

        // IMPORTANT
        // NO HORIZONTAL MARGIN

        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            18,
            16,
            18,
            16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              icon,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: unread ? FontWeight.w700 : FontWeight.w600,
                        height: 1.45,

                        // IMPORTANT
                        // distinguish read/unread

                        color: unread
                            ? colorScheme.onSurface
                            : theme.textTheme.titleSmall?.color
                                ?.withOpacity(0.78),
                      ),
                    ),
                    if (activity.subtitle != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        activity.subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: unread
                              ? subtitleColor
                              : subtitleColor.withOpacity(0.72),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  dateText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: unread
                        ? theme.textTheme.bodySmall?.color?.withOpacity(0.52)
                        : theme.textTheme.bodySmall?.color?.withOpacity(0.32),
                    fontWeight: FontWeight.w500,
                  ),
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
              spread: 0,
              glowOpacity: 0.18,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  size: 68,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No Activity Yet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Expenses, settlements and comments will appear here.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.7,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.68),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
