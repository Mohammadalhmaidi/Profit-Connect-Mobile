import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/api_call_helper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;
  final NetworkInfo networkInfo;

  static const _tokenKey = 'auth_token';

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    return safeApiCallWithNetworkCheck(
      networkInfo: networkInfo,
      call: () => remoteDataSource.login(email: email, password: password),
    );
  }

  @override
  Future<Either<Failure, UserEntity>> signup({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String role,
    List<String> skills = const [],
    String? phoneNumber,
    String? industry,
    String? companyName,
    String? companyDescription,
    String? companyIndustry,
    String? companyLocation,
  }) async {
    return safeApiCallWithNetworkCheck(
      networkInfo: networkInfo,
      call: () => remoteDataSource.signup(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        role: role,
        skills: skills,
        phoneNumber: phoneNumber,
        industry: industry,
        companyName: companyName,
        companyDescription: companyDescription,
        companyIndustry: companyIndustry,
        companyLocation: companyLocation,
      ),
    );
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    return safeApiCallWithNetworkCheck(
      networkInfo: networkInfo,
      call: () => remoteDataSource.getCurrentUser(),
    );
  }

  @override
  Future<void> saveToken(String token) async {
    await secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> logout() async {
    await secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<bool> isUserLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
