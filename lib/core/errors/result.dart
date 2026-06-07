import 'package:splittr/core/errors/failures.dart';

/// Lightweight Result type: either a [Failure] or a success value [T].
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T get value => (this as Success<T>).data;
  Failure get failure => (this as FailureResult<T>).failure;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure f) onFailure,
  }) =>
      switch (this) {
        Success<T>(:final data) => success(data),
        FailureResult<T>(:final failure) => onFailure(failure),
      };

  Result<R> map<R>(R Function(T) f) => switch (this) {
        Success<T>(:final data) => Success(f(data)),
        FailureResult<T>(:final failure) => FailureResult(failure),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);
  @override
  final Failure failure;
}

/// Convenience constructors
Result<T> ok<T>(T data) => Success(data);
Result<T> err<T>(Failure f) => FailureResult<T>(f);
