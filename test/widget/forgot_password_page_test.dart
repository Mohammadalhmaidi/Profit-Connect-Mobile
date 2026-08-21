import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _F extends ApiService {
  int calls = 0;
  bool fail = false;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> forgotPassword(String email) async {
    calls += 1;
    if (fail) throw Exception('network down');
    return _r({'success': true, 'demoCode': '1234'});
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
    builder: (c, _) => MaterialApp(
      localizationsDelegates: const [AppLocalizationDelegate()],
      supportedLocales: const [Locale('en'), Locale('ar')],
      theme: ThemeData(extensions: const [AppThemeColors.light]),
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const Scaffold()),
      home: const ForgotPasswordPage(),
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

  group('ForgotPasswordPage', () {
    testWidgets('يعرض العنوان وحقل البريد', (tester) async {
      await pumpApp(tester);

      expect(find.text('Forgot Password'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('إرسال بريد صالح يستدعي forgotPassword', (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byType(TextField), 'john@example.com');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(f.calls, 1);
    });

    testWidgets('بريد فارغ يظهر رسالة حقل مطلوب', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('This field is required'), findsOneWidget);
      expect(f.calls, 0);
    });

    testWidgets('بريد غير صالح يظهر رسالة بريد غير صالح', (tester) async {
      await pumpApp(tester);

      await tester.enterText(find.byType(TextField), 'not-an-email');
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Please enter a valid email'), findsOneWidget);
      expect(f.calls, 0);
    });
  });
}
