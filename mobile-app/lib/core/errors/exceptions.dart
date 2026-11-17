/// Typed exceptions thrown at data and network layers.
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  const ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class ForbiddenException implements Exception {
  final String message;
  const ForbiddenException(this.message);

  @override
  String toString() => 'ForbiddenException: $message';
}

class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
