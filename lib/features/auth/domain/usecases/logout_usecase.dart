import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/auth/domain/repositories/auth_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repo);
  final IAuthRepository _repo;

  Future<Result<void>> call() => _repo.logout();
}
