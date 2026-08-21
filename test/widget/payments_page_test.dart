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
import 'package:profit_connect_mobile/features/payments/presentation/pages/payments_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockAuthSocialService extends Mock implements AuthSocialService {}

class _F extends ApiService {
  List<Map<String, dynamic>> payments = [];
  bool fail = false;
  int releaseCalls = 0;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getMyPayments({String? direction, String? status}) async {
    if (fail) throw Exception('network down');
    return _r({'data': payments});
  }

  @override
  Future<Response> releasePayment(String paymentId) async {
    releaseCalls += 1;
    return _r({'success': true});
  }
}

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
        home: const PaymentsPage(),
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

  Future<void> tearDownTree(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  group('PaymentsPage', () {
    testWidgets('يعرض صفحة المدفوعات مع الفلاتر', (tester) async {
      await pumpApp(tester);

      expect(find.text('Payments'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Received'), findsOneWidget);
      expect(find.text('Sent'), findsOneWidget);
      expect(find.text('No payments found'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('يعرض المدفوعات المحمّلة', (tester) async {
      f.payments = [
        {
          '_id': 'pay1',
          'amount': 500,
          'currency': 'USD',
          'status': 'released',
          'direction': 'received',
        },
      ];

      await pumpApp(tester);

      expect(find.textContaining('500'), findsWidgets);

      await tearDownTree(tester);
    });

    testWidgets('لا يتعطل عند فشل الجلب', (tester) async {
      f.fail = true;
      await pumpApp(tester);

      expect(find.text('Payments'), findsOneWidget);

      await tearDownTree(tester);
    });
  });
}
