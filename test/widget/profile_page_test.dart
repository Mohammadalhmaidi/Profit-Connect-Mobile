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
import 'package:profit_connect_mobile/features/main_layout/presentation/manager/navigation_cubit.dart';
import 'package:profit_connect_mobile/features/profile/presentation/pages/profile_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockAuthSocialService extends Mock implements AuthSocialService {}

class _F extends ApiService {
  Map<String, dynamic> stats = {
    'postsCount': 5,
    'followersCount': 12,
    'followingCount': 3,
  };
  bool failStats = false;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<String?> getCurrentUserId() async => 'me_id';

  @override
  Future<Response> getNetworkStats() async {
    if (failStats) throw Exception('network down');
    return _r({'data': stats});
  }
}

void main() {
  late _F f;

  setUp(() {
    if (sl.isRegistered<ApiService>()) sl.unregister<ApiService>();
    f = _F();
    sl.registerSingleton<ApiService>(f);
  });

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => MaterialApp(
      localizationsDelegates: const [AppLocalizationDelegate()],
      supportedLocales: const [Locale('en'), Locale('ar')],
      theme: ThemeData(extensions: const [AppThemeColors.light]),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(
              loginUseCase: _MockLoginUseCase(),
              authRepository: _MockAuthRepository(),
              authSocialService: _MockAuthSocialService(),
            ),
          ),
          BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
        ],
        child: const ProfilePage(),
      ),
    ),
  );

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }

  group('ProfilePage (own)', () {
    testWidgets('يعرض الإحصائيات الشخصية والاسم الافتراضي للضيف', (
      tester,
    ) async {
      silenceImageErrors();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpApp(tester);

      expect(find.text('12'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('Guest User'), findsOneWidget);
    });

    testWidgets('عند فشل جلب الإحصائيات لا ينهار ويعرض الشاشة', (tester) async {
      f.failStats = true;
      await pumpApp(tester);

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Guest User'), findsOneWidget);
    });
  });
}
