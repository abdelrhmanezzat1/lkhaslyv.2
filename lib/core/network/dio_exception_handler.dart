import 'package:dio/dio.dart';
import 'package:flutter_application_1/core/error/app_exception.dart';
import 'package:flutter_application_1/core/logger/app_logger.dart';

/// A mixin to handle Dio exceptions and convert them to AppExceptions.
mixin DioExceptionHandler {
  AppException handleDioException(DioException dioException) {
    appLogger.e(
      'DioException caught',
      error: dioException,
      stackTrace: dioException.stackTrace,
    );

    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkException(
          'Connection error. Please check your network.',
          dioException.stackTrace,
        );

      case DioExceptionType.badResponse:
        final statusCode = dioException.response?.statusCode;
        final responseData = dioException.response?.data;
        final message =
            (responseData is Map ? responseData['message'] : null) ??
            'An error occurred.';

        switch (statusCode) {
          case 400:
            return BadRequestException(message, dioException.stackTrace);
          case 401:
          case 403:
            return UnauthorizedException(message, dioException.stackTrace);
          case 404:
            return NotFoundException(message, dioException.stackTrace);
          case 500:
          case 502:
            return ServerException(message, dioException.stackTrace);
          default:
            return UnknownException(
              'Received invalid status code: $statusCode',
              dioException.stackTrace,
            );
        }

      case DioExceptionType.cancel:
        // This is not an error that needs to be shown to the user.
        return UnknownException(
          'Request was cancelled.',
          dioException.stackTrace,
        );

      case DioExceptionType.badCertificate:
        return NetworkException(
          'Bad SSL certificate.',
          dioException.stackTrace,
        );

      case DioExceptionType.unknown:
      default:
        return UnknownException(
          'An unknown error occurred.',
          dioException.stackTrace,
        );
    }
  }
}
