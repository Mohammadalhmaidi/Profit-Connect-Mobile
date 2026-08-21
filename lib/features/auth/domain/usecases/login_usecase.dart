import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// [LoginUseCase] contains the business logic for user authentication.
///
/// It coordinates between the UI and the [AuthRepository] to execute a login
/// request and returns an [Either] type to handle functional errors.
class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  /// Executes the login operation.
  ///
  /// Returns [Right] with a [UserEntity] on success,
  /// or [Left] with a [Failure] on error.
  Future<Either<Failure, UserEntity>> call(LoginParams params) async =>
      repository.login(email: params.email, password: params.password);
}

/// Parameters required for the [LoginUseCase].
class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}
