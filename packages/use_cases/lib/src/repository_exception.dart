enum RepositoryFailure { unavailable, unreachable, serverError }

final class RepositoryException implements Exception {
  const RepositoryException(this.message, {this.failure = RepositoryFailure.unavailable, this.cause});

  final String message;
  final RepositoryFailure failure;
  final Object? cause;

  @override
  String toString() => 'RepositoryException: $message';
}
