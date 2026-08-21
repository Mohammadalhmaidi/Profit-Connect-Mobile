import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/settings/presentation/pages/change_password_page.dart';

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
  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    calls += 1;
    if (fail) throw Exception('network down');
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
    builder: (c, _) => MaterialApp(
      theme: ThemeData(extensions: const [AppThemeColors.light]),
      home: const ChangePasswordPage(),
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

  Future<void> fill(
    WidgetTester tester, {
    required String current,
    required String newP,
    required String confirm,
  }) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), current);
    await tester.enterText(fields.at(1), newP);
    await tester.enterText(fields.at(2), confirm);
  }

  group('ChangePasswordPage', () {
    testWidgets('يعرض الحقول الثلاثة', (tester) async {
      await pumpApp(tester);

      expect(find.text('Change Password'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('Update Password'), findsOneWidget);
    });

    testWidgets('كلمة مرور جديدة ضعيفة تظهر رسالة التحقق', (tester) async {
      await pumpApp(tester);

      await fill(
        tester,
        current: 'OldPass123',
        newP: 'short',
        confirm: 'short',
      );
      await tester.tap(find.text('Update Password'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('At least 8 characters'), findsOneWidget);
      expect(f.calls, 0);
    });

    testWidgets('نجاح التغيير يستدعي changePassword', (tester) async {
      await pumpApp(tester);

      await fill(
        tester,
        current: 'OldPass123',
        newP: 'NewPass123',
        confirm: 'NewPass123',
      );
      await tester.tap(find.text('Update Password'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(f.calls, 1);
    });

    testWidgets('فشل التغيير يعرض رسالة خطأ', (tester) async {
      f.fail = true;
      await pumpApp(tester);

      await fill(
        tester,
        current: 'OldPass123',
        newP: 'NewPass123',
        confirm: 'NewPass123',
      );
      await tester.tap(find.text('Update Password'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(f.calls, 1);
      expect(
        find.text('Failed to change password. Check your current password.'),
        findsOneWidget,
      );
    });
  });
}
