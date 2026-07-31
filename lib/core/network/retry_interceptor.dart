import 'dart:async';
import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final List<int> retryStatusCodes;

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.retryStatusCodes = const [408, 429, 500, 502, 503, 504],
  });

  @override
  void onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!retryStatusCodes.contains(err.response?.statusCode)) {
      return handler.next(err);
    }

    int retryCount = 0;
    while (retryCount < maxRetries) {
      retryCount++;
      await Future.delayed(retryDelay * retryCount);

      try {
        final response = await _retryRequest(err.requestOptions);
        return handler.resolve(response);
      } catch (e) {
        if (retryCount >= maxRetries) {
          return handler.next(err);
        }
      }
    }

    handler.next(err);
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final dio = Dio();
    dio.options.baseUrl = requestOptions.baseUrl ?? '';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);

    switch (requestOptions.method) {
      case 'GET':
        return dio.get(
          requestOptions.path,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            headers: requestOptions.headers,
            method: requestOptions.method,
          ),
        );
      case 'POST':
        return dio.post(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            headers: requestOptions.headers,
            method: requestOptions.method,
          ),
        );
      case 'PUT':
        return dio.put(
          requestOptions.path,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            headers: requestOptions.headers,
            method: requestOptions.method,
          ),
        );
      case 'DELETE':
        return dio.delete(
          requestOptions.path,
          queryParameters: requestOptions.queryParameters,
          options: Options(
            headers: requestOptions.headers,
            method: requestOptions.method,
          ),
        );
      default:
        return dio.fetch(requestOptions);
    }
  }
}