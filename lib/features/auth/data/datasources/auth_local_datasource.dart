import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/auth/data/models/user_model.dart';

abstract interface class IAuthLocalDatasource {
  Future<void> saveSession({
    required String token,
    required bool registeredNow,
    required String email,
  });
  Future<void> saveUser(UserModel user);
  Future<void> clearSession();
  UserModel? getUser();
  String? getToken();
  bool get isOnboardingDone;
  Future<void> setOnboardingDone();
}

class AuthLocalDatasource implements IAuthLocalDatasource {
  const AuthLocalDatasource(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<void> saveSession({
    required String token,
    required bool registeredNow,
    required String email,
  }) async {
    await _prefs.setString(AppConstants.prefKeyToken, token);
    await _prefs.setBool(AppConstants.prefKeyRegisteredNow, registeredNow);
    await _prefs.setString(AppConstants.prefKeyEmail, email);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(AppConstants.prefKeyUser, jsonEncode(user.toJson()));
    await HiveBoxes.me.put(AppConstants.hiveBoxMe, user);
  }

  @override
  Future<void> clearSession() async {
    await _prefs.setBool(AppConstants.prefKeyRegisteredNow, true);
    await _prefs.remove(AppConstants.prefKeyToken);
    await _prefs.remove(AppConstants.prefKeyUser);
    await HiveBoxes.me.clear();
    await HiveBoxes.users.clear();
    await HiveBoxes.shortTrips.clear();
    await HiveBoxes.trips.clear();
  }

  @override
  UserModel? getUser() {
    final raw = _prefs.getString(AppConstants.prefKeyUser);
    if (raw == null) return null;
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  @override
  String? getToken() => _prefs.getString(AppConstants.prefKeyToken);

  @override
  bool get isOnboardingDone =>
      _prefs.getBool(AppConstants.prefKeyOnboardingDone) ?? false;

  @override
  Future<void> setOnboardingDone() =>
      _prefs.setBool(AppConstants.prefKeyOnboardingDone, true);
}
