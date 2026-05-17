import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/auth/domain/entities/user_entity.dart';
import 'package:splittr/features/auth/domain/repositories/auth_repository.dart';

class OAuthLoginUseCase {
  const OAuthLoginUseCase(this._repo);
  final IAuthRepository _repo;

  Future<Result<({UserEntity user, bool isNewUser})>> call(
          String firebaseToken) =>
      _repo.oauthLogin(firebaseToken);
}
