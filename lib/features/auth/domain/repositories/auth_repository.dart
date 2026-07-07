import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

/// [AuthRepository] defines the contract for authentication operations.
/// Following the Dependency Inversion Principle, the Domain layer defines the interface
/// while the Data layer provides the implementation.
abstract class AuthRepository {
  /// Executes login and returns either a [Failure] or a [UserEntity].
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  });

  /// Persists the auth token securely on the device.
  Future<void> saveToken(String token);

  /// Retrieves the persisted auth token. Returns null if no session exists.
  Future<String?> getToken();

  /// Clears all session data (tokens, profile info) from secure storage.
  Future<void> logout();

  /// Utility to check if a valid session exists without fetching full user data.
  Future<bool> isUserLoggedIn();
}
