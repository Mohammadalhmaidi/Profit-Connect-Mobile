import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'failures.dart';
import 'dio_error_handler.dart';
import '../network/network_info.dart';

typedef ApiCall<T> = Future<T> Function();

Future<Either<Failure, T>> safeApiCall<T>(ApiCall<T> call) async {
  try {
    final result = await call();
    return Right(result);
  } on DioException catch (e) {
    return Left(handleDioError(e));
  } catch (e) {
    return Left(UnexpectedFailure(e.toString()));
  }
}

Future<Either<Failure, T>> safeApiCallWithNetworkCheck<T>({
  required NetworkInfo networkInfo,
  required ApiCall<T> call,
}) async {
  if (!await networkInfo.isConnected) {
    return const Left(ConnectionFailure('No internet connection'));
  }
  return safeApiCall(call);
}
