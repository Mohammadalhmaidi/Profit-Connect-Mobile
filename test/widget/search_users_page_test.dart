import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/network/presentation/pages/search_users_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _F extends ApiService {
  List<Map<String, dynamic>> results = [];
  bool fail = false;
  int followCalls = 0;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> searchUsers(String query, {int limit = 20}) async {
    if (fail) throw Exception('network down');
    return _r({'data': results});
  }

  @override
  Future<String?> getCurrentUserId() async => 'me_id';

  @override
  Future<Response> followUser(String userId) async {
    followCalls += 1;
    return _r({'success': true, 'following': true});
  }

  @override
  Future<Response> unfollowUser(String userId) async {
    followCalls += 1;
    return _r({'success': true, 'following': false});
  }
}

void main() {
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
      home: const SearchUsersPage(),
    ),
  );

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
  }

  Future<void> search(WidgetTester tester, String query) async {
    await tester.enterText(find.byType(TextField), query);
    await tester.pump(const Duration(milliseconds: 400));
  }

  group('SearchUsersPage', () {
    testWidgets('قبل البحث يعرض تلميح الكتابة', (tester) async {
      await pumpApp(tester);

      expect(find.text('Type at least 2 characters to search'), findsOneWidget);
      expect(find.text('Search people'), findsOneWidget);
    });

    testWidgets('البحث يعرض النتائج مع زر المتابعة', (tester) async {
      silenceImageErrors();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      f.results = [
        {
          '_id': 'u1',
          'username': 'ahmed',
          'role': 'JobSeeker',
          'profile': {
            'firstName': 'أحمد',
            'lastName': 'سالم',
            'fullname': 'أحمد سالم',
            'headline': 'Developer',
            'avatar': 'https://test.example/a.png',
            'followersCount': 5,
          },
          'isFollowing': false,
        },
      ];

      await pumpApp(tester);
      await search(tester, 'ahmed');

      expect(find.text('أحمد سالم'), findsOneWidget);
      expect(find.text('Follow'), findsOneWidget);
    });

    testWidgets('فشل البحث يعرض رسالة خطأ مع إعادة المحاولة', (tester) async {
      await pumpApp(tester);

      f.fail = true;
      await search(tester, 'xx');

      expect(find.text('Search failed. Please try again.'), findsOneWidget);

      f.fail = false;
      f.results = [];
      await tester.tap(find.text('Retry'));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Search failed. Please try again.'), findsNothing);
    });

    testWidgets('نتائج فارغة تعرض رسالة لا نتائج', (tester) async {
      await pumpApp(tester);

      f.results = [];
      await search(tester, 'zz');

      expect(find.text('No people found'), findsOneWidget);
    });

    testWidgets('زر المتابعة يستدعي followUser', (tester) async {
      silenceImageErrors();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      f.results = [
        {
          '_id': 'u1',
          'username': 'ahmed',
          'role': 'JobSeeker',
          'profile': {
            'firstName': 'أ',
            'lastName': 'ب',
            'fullname': 'أ ب',
            'avatar': 'https://test.example/a.png',
            'followersCount': 0,
          },
          'isFollowing': false,
        },
      ];

      await pumpApp(tester);
      await search(tester, 'ahmed');

      await tester.tap(find.text('Follow'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(f.followCalls, 1);
      expect(find.text('Following'), findsOneWidget);
    });
  });
}
