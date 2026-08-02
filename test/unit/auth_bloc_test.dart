import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dartz/dartz.dart';
import 'package:profit_connect_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:profit_connect_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:profit_connect_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:profit_connect_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:profit_connect_mobile/features/auth/data/services/auth_social_service.dart';
import 'package:profit_connect_mobile/core/error/failures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockAuthSocialService extends Mock implements AuthSocialService {}

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockAuthRepository mockAuthRepository;
    late MockLoginUseCase mockLoginUseCase;
    late MockAuthSocialService mockAuthSocialService;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockLoginUseCase = MockLoginUseCase();
      mockAuthSocialService = MockAuthSocialService();
      authBloc = AuthBloc(
        loginUseCase: mockLoginUseCase,
        authRepository: mockAuthRepository,
        authSocialService: mockAuthSocialService,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });

    test('LoginEvent with valid credentials emits AuthSuccess', () async {
      when(() => mockLoginUseCase(any())).thenAnswer((_) async => const Right(
            UserEntity(id: '1', email: 'test@example.com', fullName: 'Test'),
          ));

      authBloc.add(LoginSubmitted(email: 'test@example.com', password: 'password123'));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthSuccess>(),
        ]),
      );
    });

    test('LoginEvent with invalid credentials emits AuthFailure', () async {
      when(() => mockLoginUseCase(any())).thenAnswer(
        (_) async => const Left(ServerFailure('Invalid credentials')),
      );

      authBloc.add(LoginSubmitted(email: 'wrong@example.com', password: 'wrong'));

      await expectLater(
        authBloc.stream,
        emitsInOrder([
          isA<AuthLoading>(),
          isA<AuthFailure>(),
        ]),
      );
    });
  });
}
