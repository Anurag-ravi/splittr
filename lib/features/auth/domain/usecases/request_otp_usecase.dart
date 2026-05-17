import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/auth/domain/repositories/auth_repository.dart';

class RequestOtpUseCase {
  const RequestOtpUseCase(this._repo);
  final IAuthRepository _repo;

  Future<Result<String>> call(String email) => _repo.requestOtp(email);
}
