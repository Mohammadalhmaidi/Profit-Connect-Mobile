import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/feed/presentation/pages/saved_posts_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _F extends ApiService {
  List<Map<String, dynamic>> posts = [];
  bool fail = false;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getSavedPosts() async {
    if (fail) throw Exception('network down');
    return _r({'data': posts});
  }

  @override
  Future<String?> getCurrentUserId() async => 'me_id';
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
      home: const SavedPostsPage(),
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

  group('SavedPostsPage', () {
    testWidgets('يعرض المنشورات المحفوظة', (tester) async {
      silenceImageErrors();
      f.posts = [
        {
          '_id': 'p1',
          'content': 'A saved post',
          'user': {
            '_id': 'u1',
            'username': 'ahmed',
            'profile': {'fullname': 'Ahmed Salem'},
          },
          'likes': [],
          'comments': [],
          'createdAt': '2026-01-01T10:00:00.000Z',
        },
      ];

      await pumpApp(tester);

      expect(find.text('Saved Posts'), findsOneWidget);
      expect(find.text('A saved post'), findsOneWidget);
      expect(find.text('Ahmed Salem'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('حالة فارغة تعرض رسالة', (tester) async {
      await pumpApp(tester);

      expect(find.text('No saved posts yet'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('خطأ الجلب يعرض رسالة مع إعادة المحاولة', (tester) async {
      f.fail = true;
      await pumpApp(tester);

      expect(find.text('Retry'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('إعادة المحاولة بعد الفشل تعرض المنشورات', (tester) async {
      f.fail = true;
      await pumpApp(tester);

      f.fail = false;
      f.posts = [
        {
          '_id': 'p2',
          'content': 'Second post',
          'user': {
            '_id': 'u1',
            'username': 'ahmed',
            'profile': {'fullname': 'Ahmed Salem'},
          },
          'likes': [],
          'comments': [],
          'createdAt': '2026-01-01T10:00:00.000Z',
        },
      ];
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Second post'), findsOneWidget);

      await tearDownTree(tester);
    });
  });
}
