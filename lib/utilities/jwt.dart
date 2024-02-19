import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

String generateToken(String email) {
  final jwt = JWT(
    // Payload
    {'email': email},
    issuer: 'https://github.com/jonasroussel/dart_jsonwebtoken',
  );
  final token = jwt.sign(SecretKey(String.fromEnvironment('JWT_SECRET')));
  return token;
}
