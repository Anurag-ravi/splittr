import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splittr/core/constants/app_constants.dart';

/// Centralised HTTP client. All requests read url/token from SharedPreferences,
/// attach auth headers, enforce a 10-second timeout, and handle 401 by
/// clearing the session and pushing the caller to LoginPage.
class AppHttpClient {
  static const Duration _timeout = Duration(seconds: 10);

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  static Future<Map<String, dynamic>?> get(
    BuildContext context,
    String endpoint,
  ) async {
    final cfg = await _config();
    if (cfg == null) return null;
    try {
      final res = await http
          .get(Uri.parse('${cfg.url}$endpoint'), headers: cfg.headers)
          .timeout(_timeout, onTimeout: () => _timeoutResponse());
      return _handle(res, context, cfg.prefs);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> post(
    BuildContext context,
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final cfg = await _config();
    if (cfg == null) return null;
    try {
      final res = await http
          .post(
            Uri.parse('${cfg.url}$endpoint'),
            headers: cfg.headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout, onTimeout: () => _timeoutResponse());
      return _handle(res, context, cfg.prefs);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> delete(
    BuildContext context,
    String endpoint,
  ) async {
    final cfg = await _config();
    if (cfg == null) return null;
    try {
      final res = await http
          .delete(Uri.parse('${cfg.url}$endpoint'), headers: cfg.headers)
          .timeout(_timeout, onTimeout: () => _timeoutResponse());
      if (res.statusCode == 200) return jsonDecode(res.body);
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Unauthenticated POST — returns parsed JSON. Used for OTP verify and
  /// other pre-auth calls that cannot supply a BuildContext.
  static Future<Map<String, dynamic>?> postPublic(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(AppConstants.prefKeyUrl);
    if (url == null) return null;
    try {
      final res = await http
          .post(
            Uri.parse('$url$endpoint'),
            headers: {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_timeout, onTimeout: () => _timeoutResponse());
      if (res.statusCode != 200) return null;
      return jsonDecode(res.body) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Used by FCM token management — does not need a BuildContext.
  static Future<void> postNoContext(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final cfg = await _config();
    if (cfg == null) return;
    try {
      await http
          .post(
            Uri.parse('${cfg.url}$endpoint'),
            headers: cfg.headers,
            body: jsonEncode(body),
          )
          .timeout(_timeout, onTimeout: () => _timeoutResponse());
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  static http.Response _timeoutResponse() =>
      http.Response('{"status":500}', 500);

  static Future<_RequestConfig?> _config() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(AppConstants.prefKeyUrl);
    final token = prefs.getString(AppConstants.prefKeyToken);
    if (url == null || token == null) return null;
    return _RequestConfig(url: url, token: token, prefs: prefs);
  }

  static Map<String, dynamic>? _handle(
    http.Response res,
    BuildContext context,
    SharedPreferences prefs,
  ) {
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['status'] == 401) {
      _forceLogout(context, prefs);
      return null;
    }
    if (data['token'] != null) {
      prefs.setString(AppConstants.prefKeyToken, data['token'] as String);
    }
    return data;
  }

  static Future<void> _forceLogout(
    BuildContext context,
    SharedPreferences prefs,
  ) async {
    await prefs.setBool(AppConstants.prefKeyRegisteredNow, true);
    await prefs.remove(AppConstants.prefKeyToken);
    await prefs.remove(AppConstants.prefKeyUser);
    await FirebaseAuth.instance.signOut();
    // Avoid a circular import by using a dynamic push via route name.
    // The LoginPage registers itself as '/login' in main.dart.
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }
}

class _RequestConfig {
  final String url;
  final String token;
  final SharedPreferences prefs;

  const _RequestConfig({
    required this.url,
    required this.token,
    required this.prefs,
  });

  Map<String, String> get headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': token,
      };
}
