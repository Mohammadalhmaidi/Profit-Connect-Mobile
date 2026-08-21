import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/jobs/presentation/pages/my_applications_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _F extends ApiService {
  List<Map<String, dynamic>> applications = [];
  bool fail = false;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getMyApplications() async {
    if (fail) throw Exception('network down');
    return _r({'data': applications});
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
      home: const MyApplicationsPage(),
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
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  group('MyApplicationsPage', () {
    testWidgets('يعرض الطلبات مع الحالة', (tester) async {
      f.applications = [
        {
          '_id': 'a1',
          'status': 'Pending',
          'createdAt': '2026-01-05T10:00:00.000Z',
          'job': {
            'title': 'Flutter Developer',
            'location': 'Cairo',
            'type': 'Full-time',
            'company': {'name': 'Tech Co', 'logo': ''},
            'salary': {'currency': 'USD', 'min': 1000, 'max': 2000},
          },
        },
      ];

      await pumpApp(tester);

      expect(find.text('My Applications'), findsOneWidget);
      expect(find.text('Flutter Developer'), findsOneWidget);
      expect(find.text('Tech Co'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('حالة فارغة تعرض رسالة', (tester) async {
      await pumpApp(tester);

      expect(find.text('No applications yet'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('خطأ الجلب يعرض رسالة مع زر إعادة المحاولة', (tester) async {
      f.fail = true;
      await pumpApp(tester);

      expect(find.text('Could not load applications'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('إعادة المحاولة بعد الفشل تعرض الطلبات', (tester) async {
      f.fail = true;
      await pumpApp(tester);

      f.fail = false;
      f.applications = [
        {
          '_id': 'a2',
          'status': 'Accepted',
          'job': {
            'title': 'UI Designer',
            'company': {'name': 'Studio', 'logo': ''},
          },
        },
      ];
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('UI Designer'), findsOneWidget);

      await tearDownTree(tester);
    });
  });
}
