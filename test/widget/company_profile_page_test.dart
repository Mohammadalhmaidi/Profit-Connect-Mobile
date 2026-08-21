import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/auth/data/services/auth_social_service.dart';
import 'package:profit_connect_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:profit_connect_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:profit_connect_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:profit_connect_mobile/features/company/presentation/pages/company_profile_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _F extends ApiService {
  bool fail = false;
  int followCalls = 0;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getCompanyById(String companyId) async {
    if (fail) throw Exception('network down');
    return _r({
      'data': {
        '_id': companyId,
        'name': 'Tech Co',
        'industry': 'Technology',
        'description': 'Building great software',
        'followersCount': 42,
        'followers': [],
      },
    });
  }

  @override
  Future<Response> getCompanyFollowers(String companyId) async =>
      _r({'data': <Map<String, dynamic>>[]});

  @override
  Future<Response> getCompanyStats(String companyId) async => _r({
    'data': {
      'jobs': {'total': 10, 'open': 3},
      'applicants': {'total': 50},
      'followers': {
        'total': 42,
        'today': 2,
        'thisWeek': 5,
        'monthlyGrowthRate': 10,
      },
      'ratings': {'averageRating': 4.5},
    },
  });

  @override
  Future<Response> toggleFollowCompany(String companyId) async {
    followCalls += 1;
    return _r({'isFollowing': true, 'followersCount': 43});
  }
}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockAuthSocialService extends Mock implements AuthSocialService {}

void main() {
  setUpAll(loadRealFont);

  late _F f;

  setUp(() {
    if (sl.isRegistered<ApiService>()) sl.unregister<ApiService>();
    f = _F();
    sl.registerSingleton<ApiService>(f);
  });

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            loginUseCase: _MockLoginUseCase(),
            authRepository: _MockAuthRepository(),
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
        home: const CompanyProfilePage(companyId: 'c1'),
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

  group('CompanyProfilePage', () {
    testWidgets('يعرض بيانات الشركة والمتابعة', (tester) async {
      await pumpApp(tester);

      expect(find.text('Tech Co'), findsWidgets);
      expect(find.text('Technology'), findsOneWidget);
      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('عرض خطأ عند فشل الجلب مع إعادة المحاولة', (tester) async {
      f.fail = true;
      await pumpApp(tester);

      expect(find.text('Could not load company'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('إعادة المحاولة بعد الفشل تعرض الشركة', (tester) async {
      f.fail = true;
      await pumpApp(tester);

      f.fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Tech Co'), findsWidgets);
    });

    testWidgets('الضغط على متابعة يستدعي toggleFollowCompany', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Follow'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(f.followCalls, 1);
      expect(find.text('Following'), findsOneWidget);
    });
  });
}
