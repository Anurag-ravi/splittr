import 'package:splittr/features/auth/domain/entities/user_entity.dart';

/// The data carried by a successful auth action.
sealed class AuthResult {
  const AuthResult();
}

final class AuthOtpSentResult extends AuthResult {
  const AuthOtpSentResult({required this.email, required this.hash});
  final String email;
  final String hash;
}

final class AuthNewUserResult extends AuthResult {
  const AuthNewUserResult({required this.email});
  final String email;
}

final class AuthExistingUserResult extends AuthResult {
  const AuthExistingUserResult({required this.user});
  final UserEntity user;
}

final class AuthLoggedOutResult extends AuthResult {
  const AuthLoggedOutResult();
}
