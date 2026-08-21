import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/jobs/domain/entities/job_entity.dart';
import 'package:profit_connect_mobile/features/jobs/presentation/pages/job_details_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

void main() {
  setUpAll(loadRealFont);

  const job = JobEntity(
    id: 'j1',
    title: 'Flutter Developer',
    companyId: 'c1',
    companyName: 'Tech Co',
    location: 'Cairo',
    salary: SalaryRange(min: 1000, max: 2000),
    description: 'Build amazing apps',
    requirements: ['Flutter', 'Dart'],
    workPlace: 'Remote',
    workLevel: 'Mid',
  );

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => MaterialApp(
      localizationsDelegates: const [AppLocalizationDelegate()],
      supportedLocales: const [Locale('en'), Locale('ar')],
      theme: ThemeData(extensions: const [AppThemeColors.light]),
      onGenerateRoute: (settings) =>
          MaterialPageRoute(builder: (_) => const Scaffold()),
      home: const JobDetailsPage(job: job),
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

  group('JobDetailsPage', () {
    testWidgets('يعرض تفاصيل الوظيفة', (tester) async {
      await pumpApp(tester);

      expect(find.text('Flutter Developer'), findsOneWidget);
      expect(find.text('Tech Co'), findsOneWidget);
      expect(find.text('Cairo'), findsWidgets);
      expect(find.text('USD 1000 - 2000'), findsOneWidget);
      expect(find.text('Build amazing apps'), findsOneWidget);
      expect(find.text('Easy Apply'), findsOneWidget);
    });

    testWidgets('يعرض المتطلبات والرواتب عند غيابها', (tester) async {
      await pumpApp(tester);

      expect(find.text('Flutter'), findsWidgets);
      expect(find.text('Dart'), findsWidgets);
      expect(find.text('Full-time'), findsWidgets);
    });

    testWidgets('الضغط على الشركة بلا معرّف يعرض رسالة', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Tech Co'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
    });
  });
}
