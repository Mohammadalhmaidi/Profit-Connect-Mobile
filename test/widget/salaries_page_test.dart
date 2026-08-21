import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/salaries/presentation/pages/salaries_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _F extends ApiService {
  bool failOptions = false;
  int salaryCalls = 0;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getSalaryOptions() async {
    if (failOptions) throw Exception('network down');
    return _r({
      'data': {
        'titles': ['Flutter Developer'],
        'countries': ['Egypt'],
        'experienceLevels': ['Junior'],
      },
    });
  }

  @override
  Future<Response> getSalaries({
    String? title,
    String? country,
    String? experienceLevel,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    salaryCalls += 1;
    return _r({
      'data': [
        {
          'title': 'Flutter Developer',
          'country': 'Egypt',
          'average': 1500,
          'min': 1000,
          'max': 2000,
          'median': 1500,
        },
      ],
    });
  }

  @override
  Future<Response> getSalaryStats({
    String? title,
    String? country,
    String? experienceLevel,
  }) async => _r({'data': <Map<String, dynamic>>[]});
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
      home: const SalariesPage(),
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

  group('SalariesPage', () {
    testWidgets('يعرض صفحة الرواتب ويحمّل البيانات', (tester) async {
      await pumpApp(tester);

      expect(find.text('Salaries'), findsOneWidget);
      expect(f.salaryCalls, greaterThanOrEqualTo(1));

      await tearDownTree(tester);
    });

    testWidgets('لا يتعطل عند فشل الخيارات', (tester) async {
      f.failOptions = true;
      await pumpApp(tester);

      expect(find.text('Salaries'), findsOneWidget);

      await tearDownTree(tester);
    });
  });
}
