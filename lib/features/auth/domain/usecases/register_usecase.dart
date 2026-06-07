import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/auth/domain/entities/user_entity.dart';
import 'package:splittr/features/auth/domain/repositories/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repo);
  final IAuthRepository _repo;

  Future<Result<UserEntity>> call({
    required String name,
    required String countryCode,
    required String phone,
    required String upiId,
  }) =>
      _repo.register(
          name: name, countryCode: countryCode, phone: phone, upiId: upiId);
}
