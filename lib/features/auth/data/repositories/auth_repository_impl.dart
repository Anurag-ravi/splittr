import 'package:firebase_auth/firebase_auth.dart';
import 'package:splittr/core/errors/exceptions.dart';
import 'package:splittr/core/errors/failures.dart';
import 'package:splittr/core/errors/result.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:splittr/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:splittr/features/auth/domain/entities/user_entity.dart';
import 'package:splittr/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements IAuthRepository {
  const AuthRepositoryImpl({
    required IAuthRemoteDatasource remote,
    required IAuthLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  final IAuthRemoteDatasource _remote;
  final IAuthLocalDatasource _local;

  @override
  Future<Result<String>> requestOtp(String email) async {
    try {
      final hash = await _remote.requestOtp(email);
      await _local.saveSession(token: '', registeredNow: true, email: email);
      return ok(hash);
    } on ServerException catch (e) {
      return err(AuthFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<({UserEntity user, bool isNewUser})>> verifyOtp({
    required String email,
    required String otp,
    required String hash,
  }) async {
    try {
      final result =
          await _remote.verifyOtp(email: email, otp: otp, hash: hash);
      await _local.saveSession(
        token: result.token ?? '',
        registeredNow: result.isNewUser,
        email: email,
      );
      if (!result.isNewUser) await _local.saveUser(result.user);
      return ok((user: result.user.toEntity(), isNewUser: result.isNewUser));
    } on ServerException catch (e) {
      return err(AuthFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<({UserEntity user, bool isNewUser})>> oauthLogin(
      String firebaseToken) async {
    try {
      final result = await _remote.oauthLogin(firebaseToken);
      await _local.saveSession(
        token: result.token ?? '',
        registeredNow: result.isNewUser,
        email: result.user.email,
      );
      if (!result.isNewUser) await _local.saveUser(result.user);
      return ok((user: result.user.toEntity(), isNewUser: result.isNewUser));
    } on ServerException catch (e) {
      return err(AuthFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> register({
    required String name,
    required String countryCode,
    required String phone,
    required String upiId,
  }) async {
    try {
      final user = await _remote.register(
          name: name, countryCode: countryCode, phone: phone, upiId: upiId);
      await _local.saveUser(user);
      await _local.saveSession(
          token: '', registeredNow: false, email: user.email);
      return ok(user.toEntity());
    } on ServerException catch (e) {
      return err(RegistrationFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> updateProfile({
    required String name,
    required String countryCode,
    required String phone,
    required String upiId,
  }) async {
    try {
      final user = await _remote.updateProfile(
          name: name, countryCode: countryCode, phone: phone, upiId: upiId);
      await _local.saveUser(user);
      return ok(user.toEntity());
    } on ServerException catch (e) {
      return err(ServerFailure(e.message));
    } on NetworkException {
      return err(const NetworkFailure());
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final fcmToken = await _getFcmToken();
      if (fcmToken != null) {
        await AppHttpClient.postNoContext(
            '/auth/fcm-token', {'token': fcmToken, 'action': 'remove'});
      }
      await _local.clearSession();
      await FirebaseAuth.instance.signOut();
      return ok(null);
    } catch (e) {
      return err(UnknownFailure(e.toString()));
    }
  }

  @override
  UserEntity? getCachedUser() => _local.getUser()?.toEntity();

  Future<String?> _getFcmToken() async {
    // Accessed via prefs — delegated to local datasource in a real impl.
    // Kept here for simplicity.
    return null;
  }
}
