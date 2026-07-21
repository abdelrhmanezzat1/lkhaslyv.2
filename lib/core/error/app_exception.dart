/// Base class for all application-specific exceptions.
sealed class AppException implements Exception {
  final String message;
  final StackTrace? stackTrace;

  AppException(this.message, [this.stackTrace]);

  @override
  String toString() => 'AppException: $message';
}

/// Exception for network-related errors (e.g., no internet connection).
class NetworkException extends AppException {
  NetworkException([
    super.message = 'No internet connection. Please check your network.',
    super.stackTrace,
  ]);
}

/// Exception for server-side errors (e.g., 5xx status codes).
class ServerException extends AppException {
  ServerException([
    super.message = 'An unexpected server error occurred.',
    super.stackTrace,
  ]);
}

/// Exception for client-side errors indicating a bad request (e.g., 400).
class BadRequestException extends AppException {
  BadRequestException([super.message = 'Invalid request.', super.stackTrace]);
}

/// Exception for unauthorized access errors (e.g., 401, 403).
class UnauthorizedException extends AppException {
  UnauthorizedException([
    super.message = 'You are not authorized to perform this action.',
    super.stackTrace,
  ]);
}

/// Exception for when a resource is not found (e.g., 404).
class NotFoundException extends AppException {
  NotFoundException([
    super.message = 'The requested resource was not found.',
    super.stackTrace,
  ]);
}

/// Exception for unknown or unhandled errors.
class UnknownException extends AppException {
  UnknownException([
    super.message = 'An unknown error occurred.',
    super.stackTrace,
  ]);
}
