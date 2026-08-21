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
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final isRetryableStatus = retryStatusCodes.contains(
      err.response?.statusCode,
    );
    final isIdempotentMethod =
        err.requestOptions.method == 'GET' ||
        err.requestOptions.method == 'HEAD' ||
        err.requestOptions.method == 'OPTIONS';

    if (!isRetryableStatus || !isIdempotentMethod) {
      return handler.next(err);
    }

    var retryCount = 0;
    while (retryCount < maxRetries) {
      retryCount++;
      // احترام رأس Retry-After إن وُجد (خاصة 429)، وإلا تأجيل تصاعدي
      final delay = _retryAfterDelay(err) ?? retryDelay * retryCount;
      await Future.delayed(delay);

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

  Duration? _retryAfterDelay(DioException err) {
    final raw = err.response?.headers.value('retry-after');
    if (raw == null || raw.isEmpty) return null;
    final seconds = int.tryParse(raw);
    if (seconds != null && seconds > 0) {
      return Duration(seconds: seconds.clamp(0, 30));
    }
    final date = DateTime.tryParse(raw);
    if (date != null) {
      final diff = date.difference(DateTime.now());
      if (diff > Duration.zero) {
        return diff > const Duration(seconds: 30)
            ? const Duration(seconds: 30)
            : diff;
      }
    }
    return null;
  }

  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final dio = Dio();
    dio.options.baseUrl = requestOptions.baseUrl;
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
