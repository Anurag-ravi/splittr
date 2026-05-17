import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:splittr/core/errors/exceptions.dart';

/// Low-level HTTP client used by datasources.
/// Throws typed [NetworkException] / [ServerException] / [UnauthorizedException].
/// No BuildContext dependency — auth headers injected via [tokenProvider].
class ApiClient {
  ApiClient({
    required this.baseUrl,
    required this.tokenProvider,
    this.timeout = const Duration(seconds: 10),
  });

  final String baseUrl;
  final String? Function() tokenProvider;
  final Duration timeout;

  Map<String, String> get _headers {
    final token = tokenProvider();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token?.isNotEmpty == true) 'Authorization': token!,
    };
  }

  Future<Map<String, dynamic>> get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl$path'), headers: _headers)
          .timeout(timeout);
      print('headers: $_headers');
      print('response: $res');
      return _parse(res);
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    try {
      final res = await http
          .post(Uri.parse('$baseUrl$path'),
              headers: _headers, body: jsonEncode(body))
          .timeout(timeout);
      return _parse(res);
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final res = await http
          .delete(Uri.parse('$baseUrl$path'), headers: _headers)
          .timeout(timeout);
      return _parse(res);
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Map<String, dynamic> _parse(http.Response res) {
    if (res.statusCode == 401) throw const UnauthorizedException();
    if (res.statusCode != 200) {
      throw ServerException('HTTP ${res.statusCode}',
          statusCode: res.statusCode);
    }
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (data['status'] == 401) throw const UnauthorizedException();
    return data;
  }
}
