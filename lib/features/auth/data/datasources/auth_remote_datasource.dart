import 'package:splittr/core/errors/exceptions.dart';
import 'package:splittr/core/network/api_client.dart';
import 'package:splittr/features/auth/data/models/user_model.dart';

abstract interface class IAuthRemoteDatasource {
  Future<String> requestOtp(String email);
  Future<({UserModel user, bool isNewUser, String? token})> verifyOtp({
    required String email,
    required String otp,
    required String hash,
  });
  Future<({UserModel user, bool isNewUser, String? token})> oauthLogin(
      String firebaseToken);
  Future<UserModel> register({
    required String name,
    required String countryCode,
    required String phone,
    required String upiId,
  });
  Future<UserModel> updateProfile({
    required String name,
    required String countryCode,
    required String phone,
    required String upiId,
  });
}

class AuthRemoteDatasource implements IAuthRemoteDatasource {
  const AuthRemoteDatasource(this._client);
  final ApiClient _client;

  @override
  Future<String> requestOtp(String email) async {
    final data = await _client.post('/auth/otp-login', {'email': email});
    if (data['status'] != 200) {
      throw ServerException(
          data['message']?.toString() ?? 'OTP request failed');
    }
    return data['hash'] as String;
  }

  @override
  Future<({UserModel user, bool isNewUser, String? token})> verifyOtp({
    required String email,
    required String otp,
    required String hash,
  }) async {
    final data = await _client
        .post('/auth/otp-verify', {'email': email, 'otp': otp, 'hash': hash});
    if (data['status'] != 200) {
      throw ServerException(
          data['message']?.toString() ?? 'OTP verification failed');
    }
    final isNew = data['registered_now'] as bool;
    final token = data['token'] as String?;
    if (isNew) {
      return (
        user: UserModel(
          id: '',
          name: '',
          email: email,
          countryCode: '',
          phone: '',
          upiId: '',
          dp: 'cat1',
        ),
        isNewUser: true,
        token: token,
      );
    }
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      isNewUser: false,
      token: token,
    );
  }

  @override
  Future<({UserModel user, bool isNewUser, String? token})> oauthLogin(
      String firebaseToken) async {
    final data =
        await _client.post('/auth/v1/oauth-login', {'token': firebaseToken});
    if (data['status'] != 200) {
      throw ServerException(data['message']?.toString() ?? 'Login failed');
    }
    final isNew = data['registered_now'] as bool;
    final token = data['token'] as String?;
    if (isNew) {
      return (
        user: UserModel(
          id: '',
          name: '',
          email: '',
          countryCode: '',
          phone: '',
          upiId: '',
          dp: 'cat1',
        ),
        isNewUser: true,
        token: token,
      );
    }
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      isNewUser: false,
      token: token,
    );
  }

  @override
  Future<UserModel> register({
    required String name,
    required String countryCode,
    required String phone,
    required String upiId,
  }) async {
    final data = await _client.post('/auth/oauth-register', {
      'name': name,
      'country_code': countryCode,
      'number': phone,
      'upi_id': upiId,
    });
    if (data['status'] != 200) {
      throw ServerException(
          data['message']?.toString() ?? 'Registration failed');
    }
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String countryCode,
    required String phone,
    required String upiId,
  }) async {
    final data = await _client.post('/auth/update-profile', {
      'name': name,
      'country_code': countryCode,
      'number': phone,
      'upi_id': upiId,
    });
    if (data['status'] != 200) {
      throw ServerException(data['message']?.toString() ?? 'Update failed');
    }
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }
}
