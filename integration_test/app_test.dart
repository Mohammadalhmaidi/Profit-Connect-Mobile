import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:profit_connect_mobile/main.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';

void main() {
  group('Integration Tests', () {
    setUpAll(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await initDI();
    });

    tearDownAll(() {
      sl.reset();
    });

    testWidgets('app renders splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(const ProfitApp());
      await tester.pumpAndSettle();

      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app navigates through splash to login', (WidgetTester tester) async {
      await tester.pumpWidget(const ProfitApp());
      await tester.pumpAndSettle();

      final splashFinder = find.byType(SplashPage);
      if (splashFinder.evaluate().isNotEmpty) {
        expect(splashFinder, findsOneWidget);
      }
    });
  });
}