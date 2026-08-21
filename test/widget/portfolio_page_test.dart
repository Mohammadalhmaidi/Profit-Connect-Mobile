import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/feed/presentation/pages/portfolio_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _F extends ApiService {
  List<Map<String, dynamic>> items = [];
  List<Map<String, dynamic>> collections = [];
  bool fail = false;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getMyPortfolioItems({int page = 1, int limit = 12}) async {
    if (fail) throw Exception('network down');
    return _r({'data': items});
  }

  @override
  Future<Response> getMyPortfolioCollections() async =>
      _r({'data': collections});
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
      home: const PortfolioPage(),
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

  group('PortfolioPage', () {
    testWidgets('يعرض الأعمال والمجموعات', (tester) async {
      f.items = [
        {
          '_id': 'i1',
          'title': 'App Design',
          'category': 'UI/UX',
          'media': <Map<String, dynamic>>[],
          'likes': <dynamic>[],
        },
      ];
      f.collections = [
        {'_id': 'c1', 'name': 'Work 2026', 'items': <dynamic>[]},
      ];

      await pumpApp(tester);

      expect(find.text('My Portfolio'), findsOneWidget);
      expect(find.text('App Design'), findsOneWidget);
      expect(find.text('Work 2026'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('حالة فارغة تعرض رسالة', (tester) async {
      await pumpApp(tester);

      expect(find.text('No works yet'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('خطأ الجلب يعرض رسالة مع إعادة المحاولة', (tester) async {
      f.fail = true;
      await pumpApp(tester);

      expect(find.text('Retry'), findsOneWidget);

      await tearDownTree(tester);
    });
  });
}
