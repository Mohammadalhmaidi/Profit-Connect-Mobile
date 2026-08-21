import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:profit_connect_mobile/main.dart';

/// اختبارات تكامل سريعة (smoke): تُشغّل التطبيق الحقيقي بالكامل
/// وتتحقق من أنه يُبنى وينتقل من شاشة البداية دون أعطال.
/// تتطلب جهازًا/محاكيًا: flutter test integration_test
void main() {
  group('Integration Tests', () {
    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await initDI();
    });

    tearDownAll(sl.reset);

    testWidgets('app renders and shows splash screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProfitApp());
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(SplashPage), findsOneWidget);
      expect(find.byType(ScreenUtilInit), findsOneWidget);
    });

    testWidgets('app bootstraps without crashing and keeps a valid tree', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const ProfitApp());
      await tester.pump(const Duration(milliseconds: 500));

      // الشجرة سليمة ولا توجد أخطاء غير متوقعة
      expect(tester.takeException(), isNull);
      expect(find.byType(Overlay), findsWidgets);
    });
  });
}
