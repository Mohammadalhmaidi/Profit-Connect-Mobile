import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/company/presentation/pages/company_dashboard_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _F extends ApiService {
  Map<String, dynamic>? company;
  bool fail = false;

  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getMyCompany({String? companyId}) async {
    if (fail) throw Exception('network down');
    return _r({
      'data': {
        'company':
            company ??
            {'name': 'Tech Co', 'status': 'Active', 'followersCount': 10},
        'stats': {
          'jobs': {'total': 2, 'open': 1},
          'employees': {'total': 3},
        },
        'myPermissions': {'canPostJobs': true, 'canManageApplicants': true},
      },
    });
  }

  @override
  Future<Response> getCompanyEmployees(String companyId) async =>
      _r({'data': <Map<String, dynamic>>[]});

  @override
  Future<Response> getCompanyJobs({String? companyId}) async =>
      _r({'data': <Map<String, dynamic>>[]});
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
      home: const CompanyDashboardPage(companyId: 'c1'),
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

  group('CompanyDashboardPage', () {
    testWidgets('يعرض نظرة عامة وموظفين ووظائف', (tester) async {
      await pumpApp(tester);

      expect(find.text('Tech Co'), findsWidgets);
      expect(find.text('Company Dashboard'), findsOneWidget);
      expect(find.text('No employees yet'), findsOneWidget);
    });

    testWidgets('عرض الأقسام الفارغة عند غياب البيانات', (tester) async {
      await pumpApp(tester);

      expect(find.text('No employees yet'), findsOneWidget);
      expect(find.text('No jobs posted yet'), findsOneWidget);
    });

    testWidgets('لا يتعطل عند فشل الجلب', (tester) async {
      f.fail = true;
      await pumpApp(tester);

      expect(find.text('Company Dashboard'), findsOneWidget);
    });
  });
}
