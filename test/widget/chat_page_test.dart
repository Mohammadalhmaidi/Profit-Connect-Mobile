import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/messages/data/services/chat_rest_service.dart';
import 'package:profit_connect_mobile/features/messages/presentation/pages/chat_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _F extends ApiService {
  List<Map<String, dynamic>> messages = [
    {
      '_id': 'm1',
      'sender': {'_id': 'peer_id'},
      'content': 'مرحباً',
      'createdAt': '2026-01-01T10:00:00.000Z',
      'isRead': false,
    },
    {
      '_id': 'm2',
      'sender': {'_id': 'me_id'},
      'content': 'أهلاً بك',
      'createdAt': '2026-01-01T10:01:00.000Z',
      'isRead': true,
    },
  ];
  int sendCalls = 0;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<String?> getCurrentUserId() async => 'me_id';

  @override
  Future<Response> getMessages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async => _r({'data': messages});

  @override
  Future<Response> sendMessage(String conversationId, String content) async {
    sendCalls += 1;
    messages = [
      ...messages,
      {
        '_id': 'm3',
        'sender': {'_id': 'me_id'},
        'content': content,
        'createdAt': '2026-01-01T10:02:00.000Z',
        'isRead': false,
      },
    ];
    return _r({'success': true});
  }
}

void main() {
  late _F f;

  setUp(() {
    if (sl.isRegistered<ApiService>()) sl.unregister<ApiService>();
    if (sl.isRegistered<ChatRestService>()) sl.unregister<ChatRestService>();
    f = _F();
    sl.registerSingleton<ApiService>(f);
    sl.registerFactory<ChatRestService>(() => ChatRestService(f));
  });

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => MaterialApp(
      localizationsDelegates: const [AppLocalizationDelegate()],
      supportedLocales: const [Locale('en'), Locale('ar')],
      theme: ThemeData(extensions: const [AppThemeColors.light]),
      home: const ChatPage(conversationId: 'c1', userName: 'سارة'),
    ),
  );

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> tearDownTree(WidgetTester tester) async {
    // إزالة الشجرة لتفعيل dispose وإيقاف مؤقّت الاستطلاع قبل نهاية الاختبار
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  group('ChatPage', () {
    testWidgets('يعرض اسم الطرف الآخر والرسائل المحمّلة', (tester) async {
      silenceImageErrors();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpApp(tester);

      expect(find.text('سارة'), findsOneWidget);
      expect(find.text('مرحباً'), findsOneWidget);
      expect(find.text('أهلاً بك'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('إرسال رسالة يستدعي sendMessage ويعرضها', (tester) async {
      silenceImageErrors();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpApp(tester);

      await tester.enterText(find.byType(TextField), 'رسالة جديدة');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(f.sendCalls, 1);
      expect(find.text('رسالة جديدة'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('بدون رسائل يعرض حالة الدردشة الفارغة', (tester) async {
      f.messages = [];
      silenceImageErrors();

      await pumpApp(tester);

      expect(find.text('No messages yet. Say hello!'), findsOneWidget);

      await tearDownTree(tester);
    });
  });
}
