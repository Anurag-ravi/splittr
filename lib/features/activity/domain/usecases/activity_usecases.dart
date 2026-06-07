import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/activity/domain/entities/activity_entity.dart';
import 'package:splittr/features/activity/domain/repositories/activity_repository.dart';

class FetchActivityPageUseCase {
  const FetchActivityPageUseCase(this._repo);
  final IActivityRepository _repo;

  Future<Result<({List<ActivityEntity> items, int total})>> call({
    required int offset,
    required int limit,
  }) =>
      _repo.fetchPage(offset: offset, limit: limit);
}

class MarkActivityReadUseCase {
  const MarkActivityReadUseCase(this._repo);
  final IActivityRepository _repo;

  Future<Result<void>> call(String activityId) => _repo.markRead(activityId);
}
