import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/notifications/presentation/manager/notifications_cubit.dart';
import 'package:profit_connect_mobile/features/notifications/presentation/pages/notifications_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

class _F extends ApiService {
  List<Map<String, dynamic>> notifications = [
    {
      '_id': 'n1',
      'type': 'post_liked',
      'message': 'أعجب أحدهم بمنشورك',
      'read': false,
      'postId': 'p1',
      'createdAt': '2026-01-01T10:00:00.000Z',
    },
  ];
  int markAllCalls = 0;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getNotifications() async => _r({'data': notifications});

  @override
  Future<Response> markAllNotificationsRead() async {
    markAllCalls += 1;
    return _r({'success': true});
  }
}

void main() {
  late _F f;

  setUp(() {
    if (sl.isRegistered<ApiService>()) sl.unregister<ApiService>();
    if (sl.isRegistered<NotificationsCubit>()) {
      sl.unregister<NotificationsCubit>();
    }
    f = _F();
    sl.registerSingleton<ApiService>(f);
    sl.registerFactory<NotificationsCubit>(() => NotificationsCubit(f));
  });

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => MaterialApp(
      localizationsDelegates: const [AppLocalizationDelegate()],
      supportedLocales: const [Locale('en'), Locale('ar')],
      theme: ThemeData(extensions: const [AppThemeColors.light]),
      home: const NotificationsPage(),
    ),
  );

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('NotificationsPage', () {
    testWidgets('يعرض الإشعارات ويطلب تمييز الكل كمقروء عند المغادرة', (tester) async {
      await pumpApp(tester);

      final hasMessage = find
          .byWidgetPredicate(
            (w) =>
                w is RichText &&
                w.text.toPlainText().contains('أعجب أحدهم بمنشورك'),
          )
          .evaluate()
          .isNotEmpty;
      expect(hasMessage, isTrue);
      expect(f.markAllCalls, 0);

      // ترك الصفحة يؤدي إلى طلب تمييز الكل كمقروء
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(f.markAllCalls, 1);
    });

    testWidgets('عند عدم وجود إشعارات يعرض الحالة الفارغة', (tester) async {
      f.notifications = [];
      await pumpApp(tester);

      expect(find.byIcon(Icons.notifications_none), findsOneWidget);
    });

    testWidgets('عند فشل الجلب يعرض رسالة الخطأ', (tester) async {
      sl.unregister<NotificationsCubit>();
      sl.registerFactory<NotificationsCubit>(
        () => NotificationsCubit(_ThrowingApi()),
      );
      await pumpApp(tester);

      expect(find.text('Something went wrong'), findsOneWidget);
    });
  });
}

class _ThrowingApi extends ApiService {
  @override
  Future<Response> getNotifications() async => throw Exception('network down');

  @override
  Future<Response> markAllNotificationsRead() async =>
      throw Exception('network down');
}
