import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/auth/domain/entities/user_entity.dart';
import 'package:splittr/features/auth/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase {
  const VerifyOtpUseCase(this._repo);
  final IAuthRepository _repo;

  Future<Result<({UserEntity user, bool isNewUser})>> call({
    required String email,
    required String otp,
    required String hash,
  }) =>
      _repo.verifyOtp(email: email, otp: otp, hash: hash);
}
