/// Exceptions thrown by the data layer; caught and converted to [Failure] in repositories.

class NetworkException implements Exception {
  const NetworkException([this.message = 'Network error.']);
  final String message;
}

class TimeoutException implements Exception {
  const TimeoutException([this.message = 'Request timed out.']);
  final String message;
}

class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
}

class UnauthorizedException implements Exception {
  const UnauthorizedException([this.message = 'Unauthorized.']);
  final String message;
}

class CacheException implements Exception {
  const CacheException([this.message = 'Cache error.']);
  final String message;
}

class NotFoundException implements Exception {
  const NotFoundException([this.message = 'Not found.']);
  final String message;
}

class ValidationException implements Exception {
  const ValidationException(this.message);
  final String message;
}
