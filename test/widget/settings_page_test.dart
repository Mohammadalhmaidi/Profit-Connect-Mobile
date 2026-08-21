import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/presentation/manager/app_settings_cubit.dart';
import 'package:profit_connect_mobile/core/presentation/manager/theme_bloc.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/auth/data/services/auth_social_service.dart';
import 'package:profit_connect_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:profit_connect_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:profit_connect_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:profit_connect_mobile/features/settings/presentation/pages/settings_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_utils.dart';

class _F extends ApiService {
  int updateCalls = 0;
  int logoutCalls = 0;
  Map<String, dynamic> settings = {'emailNotifications': true};

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getSettings() async => _r({'data': settings});

  @override
  Future<Response> updateSettings(Map<String, dynamic> data) async {
    updateCalls += 1;
    settings.addAll(data);
    return _r({'success': true});
  }

  @override
  Future<void> logout() async {
    logoutCalls += 1;
  }
}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockAuthSocialService extends Mock implements AuthSocialService {}

void main() {
  setUpAll(loadRealFont);

  late _F f;
  late SharedPreferences prefs;
  late _MockAuthRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    if (sl.isRegistered<ApiService>()) sl.unregister<ApiService>();
    f = _F();
    sl.registerSingleton<ApiService>(f);
    repo = _MockAuthRepository();
    when(() => repo.logout()).thenAnswer((_) async {});
  });

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (_) => ThemeBloc(sharedPreferences: prefs),
        ),
        BlocProvider<AppSettingsCubit>(
          create: (_) => AppSettingsCubit(sharedPreferences: prefs),
        ),
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: _MockLoginUseCase(),
            authRepository: repo,
            authSocialService: _MockAuthSocialService(),
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [AppLocalizationDelegate()],
        supportedLocales: const [Locale('en'), Locale('ar')],
        theme: ThemeData(extensions: const [AppThemeColors.light]),
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => const Scaffold()),
        home: const SettingsPage(),
      ),
    ),
  );

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 9000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('SettingsPage', () {
    testWidgets('يعرض أقسام الإعدادات', (tester) async {
      await pumpApp(tester);

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Email Notifications'), findsOneWidget);
      expect(find.text('Log Out'), findsOneWidget);
    });

    testWidgets('تبديل إشعارات البريد يستدعي updateSettings', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.byType(Switch).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(f.updateCalls, greaterThanOrEqualTo(1));
    });

    testWidgets('زر تسجيل الخروج يستدعي logout', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Log Out'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(f.logoutCalls, 1);
    });
  });
}
