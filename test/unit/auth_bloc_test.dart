import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:profit_connect_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:profit_connect_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:profit_connect_mobile/features/auth/domain/repositories/auth_repository.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

void main() {
  group('AuthBloc', () {
    late AuthBloc authBloc;
    late MockAuthRepository mockAuthRepository;
    late MockLoginUseCase mockLoginUseCase;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockLoginUseCase = MockLoginUseCase();
      authBloc = AuthBloc(
        loginUseCase: mockLoginUseCase,
        authRepository: mockAuthRepository,
      );
    });

    tearDown(() {
      authBloc.close();
    });

    test('initial state is AuthInitial', () {
      expect(authBloc.state, AuthInitial());
    });

    test('LoginEvent with valid credentials emits AuthSuccess', () async {
      when(() => mockLoginUseCase(any())).thenAnswer((_) async => const Right(UserEntity(id: '1', email: 'test@example.com')));

      authBloc.add(LoginEvent(email: 'test@example.com', password: 'password123'));

      await until(() => authBloc.state is AuthSuccess);
      expect(authBloc.state, isA<AuthSuccess>());
    });

    test('LoginEvent with invalid credentials emits AuthFailure', () async {
      when(() => mockLoginUseCase(any())).thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

      authBloc.add(LoginEvent(email: 'wrong@example.com', password: 'wrong'));

      await until(() => authBloc.state is AuthFailure);
      expect(authBloc.state, isA<AuthFailure>());
    });
  });
}