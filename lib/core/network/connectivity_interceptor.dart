import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityInterceptor extends Interceptor {
  final InternetConnection _connectionChecker;

  ConnectivityInterceptor(this._connectionChecker);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (kIsWeb) {
      return handler.next(options);
    }
    final hasConnection = await _connectionChecker.hasInternetAccess;
    if (!hasConnection) {
      return handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          message: 'No internet connection',
        ),
      );
    }
    return handler.next(options);
  }
}
