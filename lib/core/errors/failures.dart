import 'package:equatable/equatable.dart';

/// Base class for all domain-layer failures.
sealed class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

// ── Network ───────────────────────────────────────────────────────────────────

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error. Please try again.']);
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out.']);
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error.']);
}

// ── Auth ─────────────────────────────────────────────────────────────────────

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Session expired. Please log in again.']);
}

final class RegistrationFailure extends Failure {
  const RegistrationFailure([super.message = 'Registration failed.']);
}

// ── Validation ───────────────────────────────────────────────────────────────

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// ── Storage ──────────────────────────────────────────────────────────────────

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local storage error.']);
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Item not found.']);
}

// ── Domain ───────────────────────────────────────────────────────────────────

final class BalanceNotSettledFailure extends Failure {
  const BalanceNotSettledFailure([super.message = 'Outstanding balances must be settled first.']);
}

final class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An unexpected error occurred.']);
}
