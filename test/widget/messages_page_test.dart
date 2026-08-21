import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/messages/presentation/pages/messages_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';
import '../helpers/test_utils.dart';

Map<String, dynamic> _u(String id, String fn, String ln) => {
  '_id': id,
  'profile': {
    'firstName': fn,
    'lastName': ln,
    'avatar': 'https://test.example/a.png',
  },
};

Map<String, dynamic> _c(
  String id,
  Map<String, dynamic> peer,
  String content,
  String peerId,
) => {
  '_id': id,
  'lastMessageAt': '2026-01-01T10:00:00.000Z',
  'lastMessage': {'content': content, 'createdAt': '2026-01-01T10:00:00.000Z'},
  'participants': [
    {
      '_id': 'me',
      'profile': {'firstName': 'أنا', 'lastName': 'المستخدم'},
    },
    {...peer, '_id': peerId},
  ],
};

class _F extends ApiService {
  Map<String, dynamic> convos = {};
  Map<String, dynamic> convosSearch = {};
  Map<String, dynamic> srch = {};

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getConversations({
    int page = 1,
    int limit = 20,
    String? q,
  }) async {
    if (q != null && q.trim().isNotEmpty) return _r(convosSearch);
    return _r(convos);
  }

  @override
  Future<Response> searchUsers(String q, {int limit = 20}) async => _r(srch);

  @override
  Future<String?> getCurrentUserId() async => 'me';

  @override
  Future<Response> followUser(String u) async => _r({});
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
      home: const MessagesPage(),
    ),
  );

  group('MessagesPage', () {
    testWidgets('renders conversation names and last messages', (tester) async {
      silenceImageErrors();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final pA = _u('a1', 'Ahmed', 'Salem');
      final pB = _u('b1', 'Mona', 'Fadel');
      f.convos = {
        'data': [
          _c('c1', pA, 'How are you?', 'a1'),
          _c('c2', pB, 'File sent', 'b1'),
        ],
      };

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Ahmed Salem'), findsOneWidget);
      expect(find.text('How are you?'), findsOneWidget);
    });

    testWidgets('search by peer name filters conversations', (tester) async {
      silenceImageErrors();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final pA = _u('a1', 'Ahmed', 'Salem');
      final pB = _u('b1', 'Mona', 'Fadel');
      f.convos = {
        'data': [_c('c1', pA, 'msg', 'a1'), _c('c2', pB, 'msg2', 'b1')],
      };
      f.convosSearch = {
        'data': [_c('c2', pB, 'msg2', 'b1')],
      };
      f.srch = {'data': []};

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'Mona');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Mona Fadel'), findsOneWidget);
      expect(find.text('Ahmed Salem'), findsNothing);
    });

    testWidgets('single char search keeps full list (server not called)', (
      tester,
    ) async {
      silenceImageErrors();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final pA = _u('a1', 'Ahmed', 'Salem');
      f.convos = {
        'data': [_c('c1', pA, 'msg', 'a1')],
      };

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.enterText(find.byType(TextField), 'A');
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Ahmed Salem'), findsOneWidget);
    });
  });
}
