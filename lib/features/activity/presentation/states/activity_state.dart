import 'package:splittr/features/activity/domain/entities/activity_entity.dart';

/// The data shape for the activity feed — list + pagination metadata.
class ActivityFeedData {
  const ActivityFeedData({
    required this.items,
    required this.hasMore,
    this.loadingMore = false,
    this.loadingId,
  });

  final List<ActivityEntity> items;
  final bool hasMore;
  final bool loadingMore;
  final String? loadingId;

  ActivityFeedData copyWith({
    List<ActivityEntity>? items,
    bool? hasMore,
    bool? loadingMore,
    String? loadingId,
    bool clearLoadingId = false,
  }) =>
      ActivityFeedData(
        items: items ?? this.items,
        hasMore: hasMore ?? this.hasMore,
        loadingMore: loadingMore ?? this.loadingMore,
        loadingId: clearLoadingId ? null : loadingId ?? this.loadingId,
      );
}
