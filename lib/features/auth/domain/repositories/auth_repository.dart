import 'package:splittr/core/errors/result.dart';
import 'package:splittr/features/auth/domain/entities/user_entity.dart';

abstract interface class IAuthRepository {
  Future<Result<String>> requestOtp(String email);
  Future<Result<({UserEntity user, bool isNewUser})>> verifyOtp({
    required String email,
    required String otp,
    required String hash,
  });
  Future<Result<({UserEntity user, bool isNewUser})>> oauthLogin(String firebaseToken);
  Future<Result<UserEntity>> register({
    required String name,
    required String countryCode,
    required String phone,
    required String upiId,
  });
  Future<Result<UserEntity>> updateProfile({
    required String name,
    required String countryCode,
    required String phone,
    required String upiId,
  });
  Future<Result<void>> logout();
  UserEntity? getCachedUser();
}
