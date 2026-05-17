import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/core/constants/app_constants.dart';
import 'package:splittr/core/network/http_client.dart';
import 'package:splittr/core/storage/hive_boxes.dart';
import 'package:splittr/features/auth/data/models/user_model.dart';

class AuthRepository {
  const AuthRepository(this._prefs);

  final SharedPreferences _prefs;

  Future<Map<String, dynamic>?> requestOtp(
          BuildContext context, String email) =>
      AppHttpClient.post(context, '/auth/otp-login', {'email': email});

  Future<Map<String, dynamic>?> verifyOtp(
          String email, String otp, String hash) =>
      AppHttpClient.postPublic(
          '/auth/otp-verify', {'email': email, 'otp': otp, 'hash': hash});

  Future<Map<String, dynamic>?> oauthLogin(
          BuildContext context, String firebaseToken) =>
      AppHttpClient.post(
          context, '/auth/v1/oauth-login', {'token': firebaseToken});

  Future<Map<String, dynamic>?> register(
    BuildContext context, {
    required String name,
    required String countryCode,
    required String number,
    required String upiId,
  }) =>
      AppHttpClient.post(context, '/auth/oauth-register', {
        'name': name,
        'country_code': countryCode,
        'number': number,
        'upi_id': upiId,
      });

  Future<Map<String, dynamic>?> updateProfile(
    BuildContext context, {
    required String name,
    required String countryCode,
    required String number,
    required String upiId,
  }) =>
      AppHttpClient.post(context, '/auth/update-profile', {
        'name': name,
        'country_code': countryCode,
        'number': number,
        'upi_id': upiId,
      });

  Future<void> saveSession({
    required String token,
    required bool registeredNow,
    required String email,
  }) async {
    await _prefs.setString(AppConstants.prefKeyToken, token);
    await _prefs.setBool(AppConstants.prefKeyRegisteredNow, registeredNow);
    await _prefs.setString(AppConstants.prefKeyEmail, email);
  }

  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(AppConstants.prefKeyUser, jsonEncode(user.toJson()));
    await HiveBoxes.me.put('me', user);
  }

  Future<void> logout() async {
    final fcmToken = _prefs.getString(AppConstants.prefKeyFcmToken);
    if (fcmToken != null) {
      await AppHttpClient.postNoContext(
          '/auth/fcm-token', {'token': fcmToken, 'action': 'remove'});
      await _prefs.remove(AppConstants.prefKeyFcmToken);
    }
    await _prefs.setBool(AppConstants.prefKeyRegisteredNow, true);
    await _prefs.remove(AppConstants.prefKeyToken);
    await _prefs.remove(AppConstants.prefKeyUser);
    HiveBoxes.me.clear();
    HiveBoxes.users.clear();
    HiveBoxes.shortTrips.clear();
    HiveBoxes.trips.clear();
    await FirebaseAuth.instance.signOut();
  }

  UserModel? currentUser() => HiveBoxes.me.get('me');

  bool get isLoggedIn => _prefs.getString(AppConstants.prefKeyToken) != null;

  bool get onboardingDone =>
      _prefs.getBool(AppConstants.prefKeyOnboardingDone) ?? false;

  bool get registeredNow =>
      _prefs.getBool(AppConstants.prefKeyRegisteredNow) ?? true;

  String get savedEmail => _prefs.getString(AppConstants.prefKeyEmail) ?? '';

  Future<void> completeOnboarding() =>
      _prefs.setBool(AppConstants.prefKeyOnboardingDone, true);
}
