import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/auth/data/services/auth_social_service.dart';
import 'package:profit_connect_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:profit_connect_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:profit_connect_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:profit_connect_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:profit_connect_mobile/features/auth/presentation/pages/signup_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockAuthSocialService extends Mock implements AuthSocialService {}

void main() {
  setUpAll(loadRealFont);

  late _MockAuthRepository repo;
  late _MockLoginUseCase login;
  late _MockAuthSocialService social;

  setUp(() {
    repo = _MockAuthRepository();
    login = _MockLoginUseCase();
    social = _MockAuthSocialService();
  });

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            loginUseCase: login,
            authRepository: repo,
            authSocialService: social,
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [AppLocalizationDelegate()],
        supportedLocales: const [Locale('en'), Locale('ar')],
        theme: ThemeData(extensions: const [AppThemeColors.light]),
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => const Scaffold()),
        home: const SignUpPage(),
      ),
    ),
  );

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 15000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> tapSubmit(WidgetTester tester) async {
    final btn = find.text('Create Account').last;
    await tester.tap(btn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('SignUpPage', () {
    testWidgets('يعرض الحقول ونموذج التسجيل', (tester) async {
      await pumpApp(tester);

      expect(find.text('Create Account'), findsWidgets);
      expect(find.byType(TextFormField), findsAtLeast(4));
      expect(find.text('Skills (select at least 3)'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
    });

    testWidgets('كلمة مرور قصيرة تظهر رسالة التحقق', (tester) async {
      await pumpApp(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), 'short');
      await tapSubmit(tester);

      expect(find.text('At least 8 characters'), findsOneWidget);
    });

    testWidgets('كلمة مرور بلا حرف كبير تظهر رسالة التحقق', (tester) async {
      await pumpApp(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), 'abcdef12');
      await tapSubmit(tester);

      expect(find.text('Must contain an uppercase letter'), findsOneWidget);
    });

    testWidgets('إرسال صالح يستدعي signup', (tester) async {
      when(
        () => repo.signup(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
          role: any(named: 'role'),
          skills: any(named: 'skills'),
          gender: any(named: 'gender'),
        ),
      ).thenAnswer(
        (_) async => right(
          const UserEntity(
            id: 'u1',
            email: 'john@example.com',
            fullName: 'John Doe',
          ),
        ),
      );

      await pumpApp(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John Doe');
      await tester.enterText(fields.at(1), 'john@example.com');
      await tester.enterText(fields.at(2), 'Password123');
      await tester.enterText(fields.at(3), 'Password123');
      for (final skill in ['Flutter', 'Python', 'Coding']) {
        await tester.tap(find.text(skill));
        await tester.pump();
      }

      await tapSubmit(tester);

      verify(
        () => repo.signup(
          firstName: 'John',
          lastName: 'Doe',
          email: 'john@example.com',
          password: 'Password123',
          role: 'JobSeeker',
          skills: ['Flutter', 'Python', 'Coding'],
        ),
      ).called(1);
    });
  });
}
