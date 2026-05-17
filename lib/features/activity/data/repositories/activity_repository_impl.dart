import 'package:splittr/core/errors/exceptions.dart';
import 'package:splittr/core/errors/failures.dart';
import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/activity/data/datasources/activity_remote_datasource.dart';
import 'package:splittr/features/activity/domain/entities/activity_entity.dart';
import 'package:splittr/features/activity/domain/repositories/activity_repository.dart';

class ActivityRepositoryImpl implements IActivityRepository {
  const ActivityRepositoryImpl(this._remote);
  final IActivityRemoteDatasource _remote;

  @override
  Future<Result<({List<ActivityEntity> items, int total})>> fetchPage({
    required int offset, required int limit,
  }) async {
    try {
      final result = await _remote.fetchPage(offset: offset, limit: limit);
      return ok((
        items: result.items.map((m) => m.toEntity()).toList(),
        total: result.total,
      ));
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markRead(String activityId) async {
    try {
      await _remote.markRead(activityId);
      return ok(null);
    } catch (_) {
      return ok(null); // fire-and-forget — never fail the UI for this
    }
  }
}
