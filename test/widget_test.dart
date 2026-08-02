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
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockAuthSocialService extends Mock implements AuthSocialService {}

void main() {
  testWidgets('LoginPage loads correctly and shows essential fields', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      ScreenUtilInit(
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
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Welcome to CareerPath'), findsOneWidget);
    expect(find.text('Log In'), findsWidgets);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('name@example.com'), findsOneWidget);
  });
}
