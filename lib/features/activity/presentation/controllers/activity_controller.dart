import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splittr/core/providers/domain_providers.dart';
import 'package:splittr/features/activity/domain/entities/activity_entity.dart';
import 'package:splittr/features/activity/presentation/states/activity_state.dart';
import 'package:splittr/shared/services/activity_navigator.dart';

class ActivityNotifier extends AsyncNotifier<ActivityFeedData> {
  static const _limit = 20;
  int _offset = 0;

  @override
  Future<ActivityFeedData> build() => _fetchPage(reset: true);

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = AsyncData(await _fetchPage(reset: true));
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || current.loadingMore || !current.hasMore) return;
    state = AsyncData(current.copyWith(loadingMore: true));

    final result = await ref
        .read(fetchActivityPageUseCaseProvider)
        .call(offset: _offset, limit: _limit);

    result.when(
      success: (page) {
        final updated = [...current.items, ...page.items];
        _offset = updated.length;
        state = AsyncData(ActivityFeedData(
          items: updated,
          hasMore: updated.length < page.total,
        ));
      },
      onFailure: (_) {
        state = AsyncData(current.copyWith(loadingMore: false));
      },
    );
  }

  Future<void> tapActivity(
      BuildContext context, ActivityEntity activity) async {
    final current = state.value;
    if (current == null) return;

    state = AsyncData(current.copyWith(loadingId: activity.id));

    if (!activity.read) {
      await ref.read(markActivityReadUseCaseProvider).call(activity.id);
      final updated = current.items
          .map((a) => a.id == activity.id ? a.copyWith(read: true) : a)
          .toList();
      state = AsyncData(current.copyWith(items: updated, loadingId: activity.id));
    }

    if (!context.mounted) return;
    await ActivityNavigator.navigate(
        context, activity.entityId, activity.entityType);
    if (!context.mounted) return;

    final s = state.value;
    if (s != null) state = AsyncData(s.copyWith(clearLoadingId: true));
  }

  Future<ActivityFeedData> _fetchPage({required bool reset}) async {
    if (reset) _offset = 0;
    final result = await ref
        .read(fetchActivityPageUseCaseProvider)
        .call(offset: _offset, limit: _limit);

    return result.when(
      success: (page) {
        _offset = page.items.length;
        return ActivityFeedData(
          items: page.items,
          hasMore: page.items.length < page.total,
        );
      },
      onFailure: (f) => throw Exception(f.message),
    );
  }
}
