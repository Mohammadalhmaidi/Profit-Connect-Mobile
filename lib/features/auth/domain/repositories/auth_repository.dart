import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

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
    String? avatarPath,
    String? gender,
  });

  Future<Either<Failure, UserEntity>> getCurrentUser();

  Future<void> saveToken(String token);

  Future<String?> getToken();

  Future<void> logout();

  Future<bool> isUserLoggedIn();
}
