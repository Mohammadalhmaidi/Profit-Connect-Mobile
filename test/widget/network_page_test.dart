import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/network/presentation/pages/network_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

Map<String, dynamic> _u(String id, String fn, String ln, {String hl = ''}) => {
  '_id': id,
  'username': 'u_$id',
  'role': 'JobSeeker',
  'profile': {
    'firstName': fn,
    'lastName': ln,
    'fullname': '$fn $ln',
    'headline': hl,
    'avatar': 'https://test.example/a.png',
    'followersCount': 3,
  },
};

Map<String, dynamic> _disc(
  Map<String, dynamic> u, {
  String cs = 'none',
  bool isf = false,
}) => {
  '_id': u['_id'],
  'username': u['username'],
  'role': u['role'],
  'profile': u['profile'],
  'isFollowing': isf,
  'connectionStatus': cs,
};

class _F extends ApiService {
  Map<String, dynamic> req = {};
  Map<String, dynamic> conn = {};
  Map<String, dynamic> disc = {};
  Map<String, dynamic> Function(String q) srch = (_) => {};
  int ac = 0;
  int sc = 0;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getNetworkRequests() async => _r(req);
  @override
  Future<Response> getMyConnectionsList() async => _r(conn);
  @override
  Future<Response> getDiscoverUsers({int limit = 10}) async => _r(disc);
  @override
  Future<Response> searchUsers(String q, {int limit = 20}) async => _r(srch(q));
  @override
  Future<Response> acceptConnectionRequest(String id) async {
    ac++;
    return _r({});
  }

  @override
  Future<Response> sendConnectionRequest(String id) async {
    sc++;
    return _r({});
  }

  @override
  Future<Response> followUser(String uid) async => _r({});
  @override
  Future<Response> unfollowUser(String uid) async => _r({});
  @override
  Future<Response> rejectConnectionRequest(String id) async => _r({});
}

void main() {
  late _F f;

  /// يكتم أخطاء NetworkImage حتى لا تفسد الاختبار، ويرمم المعالج الأصلي بعد نهاية الاختبار الحالي
  void silenceImages() {
    final prev = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception is NetworkImageLoadException) return;
      prev?.call(details);
    };
    addTearDown(() {
      FlutterError.onError = prev;
    });
  }

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
      home: const NetworkPage(),
    ),
  );

  group('NetworkPage', () {
    testWidgets('renders requests with user names', (tester) async {
      silenceImages();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      f.req = {
        'data': [
          {'_id': 'r1', 'requester': _u('u1', 'Ahmed', 'Salem', hl: 'Dev')},
        ],
      };
      f.conn = {'data': []};
      f.disc = {'data': []};

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Ahmed Salem'), findsOneWidget);
    });

    testWidgets('accept button removes request', (tester) async {
      silenceImages();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      f.req = {
        'data': [
          {'_id': 'r1', 'requester': _u('u1', 'Ahmed', 'Salem')},
        ],
      };

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Ahmed Salem'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton).first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(f.ac, 1);
      expect(find.text('Ahmed Salem'), findsNothing);
    });

    testWidgets('suggestion excludes connected users', (tester) async {
      silenceImages();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final con = _u('c1', 'Linked', 'User');
      final str = _u('s1', 'New', 'Person');
      f.conn = {
        'data': [con],
      };
      f.disc = {
        'data': [_disc(con, cs: 'accepted'), _disc(str)],
      };

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // انتقل لتبويب الاتصالات (Connections) حيث تظهر المقترحات
      await tester.tap(find.byType(Tab).last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // المقترحات: المستخدم الجديد "New Person" فقط دون المتصل "Linked User"
      expect(find.text('New Person'), findsOneWidget);
      // "Linked User" يظهر فقط في شبكة الاتصالات (مرة واحدة)، وليس في المقترحات
      expect(find.text('Linked User'), findsNWidgets(1));
    });

    testWidgets('search connected shows check icon', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      f.srch = (q) => {
        'data': [
          _disc(_u('c1', 'Linked', 'User'), cs: 'accepted'),
          _disc(_u('s1', 'New', 'Person')),
        ],
      };

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'any');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.person_add_alt), findsWidgets);
    });

    testWidgets('empty search shows no results', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      f.srch = (q) => {'data': []};

      await tester.pumpWidget(buildApp());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'nothing');
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });
}
