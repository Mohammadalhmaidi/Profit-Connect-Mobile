import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/auth/presentation/pages/reset_password_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _F extends ApiService {
  int resetCalls = 0;
  bool fail = false;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    resetCalls += 1;
    if (fail) throw Exception('network down');
    return _r({'success': true});
  }

  @override
  Future<Response> forgotPassword(String email) async =>
      _r({'success': true, 'demoCode': '1234'});
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
      home: const ResetPasswordPage(email: 'john@example.com'),
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

  Future<void> enterOtp(WidgetTester tester) async {
    for (final d in ['1', '2', '3', '4']) {
      await tester.tap(find.text(d));
      await tester.pump();
    }
  }

  group('ResetPasswordPage', () {
    testWidgets('يعرض شاشة التحقق وحقول كلمة المرور', (tester) async {
      await pumpApp(tester);

      expect(find.text('Verify & Reset'), findsOneWidget);
      expect(find.text('john@example.com'), findsOneWidget);
      expect(find.byType(TextField), findsAtLeast(2));
      expect(find.text('Reset Password'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('OTP ناقص يبقي الزر معطلًا', (tester) async {
      await pumpApp(tester);

      final button = tester.widget<ElevatedButton>(
        find.ancestor(
          of: find.text('Reset Password'),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(button.onPressed, isNull);

      await tearDownTree(tester);
    });

    testWidgets('إدخال كلمة مرور ضعيفة يعرض رسالة التحقق', (tester) async {
      await pumpApp(tester);

      await enterOtp(tester);
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'short');
      await tester.enterText(fields.at(1), 'short');
      await tester.tap(find.text('Reset Password'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('At least 8 characters'), findsOneWidget);
      expect(f.resetCalls, 0);

      await tearDownTree(tester);
    });

    testWidgets('إعادة تعيين صالحة تستدعي resetPassword', (tester) async {
      await pumpApp(tester);

      await enterOtp(tester);
      final fields = find.byType(TextField);
      await tester.enterText(fields.at(0), 'Password123');
      await tester.enterText(fields.at(1), 'Password123');
      await tester.tap(find.text('Reset Password'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(f.resetCalls, 1);

      await tearDownTree(tester);
    });
  });
}
