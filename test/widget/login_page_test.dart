import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:profit_connect_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:profit_connect_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:profit_connect_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:profit_connect_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:profit_connect_mobile/features/auth/data/services/auth_social_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockAuthSocialService extends Mock implements AuthSocialService {}

Widget _wrapLoginPage() {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, child) => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            loginUseCase: MockLoginUseCase(),
            authRepository: MockAuthRepository(),
            authSocialService: MockAuthSocialService(),
          ),
        ),
      ],
      child: const MaterialApp(home: LoginPage()),
    ),
  );
}

void main() {
  group('LoginPage Widget Tests', () {
    testWidgets('renders email and password fields', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_wrapLoginPage());

      expect(find.byType(TextField), findsAtLeast(2));
      expect(find.text('Log In'), findsWidgets);
    });

    testWidgets('shows validation error on empty fields', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;

      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(_wrapLoginPage());

      final loginButton = find.text('Log In');
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });
  });
}
