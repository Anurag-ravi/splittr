import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/activity/domain/entities/activity_entity.dart';

abstract interface class IActivityRepository {
  Future<Result<({List<ActivityEntity> items, int total})>> fetchPage({
    required int offset,
    required int limit,
  });
  Future<Result<void>> markRead(String activityId);
}
