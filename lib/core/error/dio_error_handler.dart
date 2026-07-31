import 'package:dio/dio.dart';
import 'failures.dart';

Failure handleDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const TimeoutFailure();

    case DioExceptionType.connectionError:
      return const ConnectionFailure('No internet connection');

    case DioExceptionType.badResponse:
      return _handleStatusCode(e);

    case DioExceptionType.cancel:
      return const ServerFailure('Request cancelled');

    case DioExceptionType.badCertificate:
      return const ServerFailure('Bad certificate');

    case DioExceptionType.unknown:
      return UnexpectedFailure(e.message ?? 'Unknown error occurred');
  }
}

Failure _handleStatusCode(DioException e) {
  final statusCode = e.response?.statusCode;
  final data = e.response?.data;
  final message = data is Map ? (data['message'] ?? data['error'] ?? 'Unknown error') : 'Unknown error';

  switch (statusCode) {
    case 400:
      return ValidationFailure(
        message is String ? message : 'Validation failed',
        errors: data is Map ? (data['errors'] is Map<String, dynamic> ? data['errors'] as Map<String, dynamic> : null) : null,
      );
    case 401:
      return UnauthorizedFailure(message is String ? message : 'Unauthorized');
    case 403:
      return const ServerFailure('Forbidden', statusCode: 403);
    case 404:
      return NotFoundFailure(message is String ? message : 'Not found');
    case 422:
      return ValidationFailure(
        message is String ? message : 'Validation failed',
        errors: data is Map ? (data['errors'] is Map<String, dynamic> ? data['errors'] as Map<String, dynamic> : null) : null,
      );
    case 500:
      return const ServerFailure('Internal server error', statusCode: 500);
    default:
      return ServerFailure(
        message is String ? message : 'Server error',
        statusCode: statusCode,
      );
  }
}
