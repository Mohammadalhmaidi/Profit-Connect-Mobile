import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/jobs/domain/entities/job_entity.dart';
import 'package:profit_connect_mobile/features/jobs/domain/usecases/get_jobs_usecase.dart';
import 'package:profit_connect_mobile/features/jobs/presentation/manager/jobs_bloc.dart';
import 'package:profit_connect_mobile/features/jobs/presentation/pages/job_search_results_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _MockGetJobs extends Mock implements GetJobsUseCase {}

void main() {
  setUpAll(loadRealFont);

  late _MockGetJobs useCase;

  setUp(() {
    useCase = _MockGetJobs();
    when(
      () => useCase.call(
        search: any(named: 'search'),
        type: any(named: 'type'),
        workPlace: any(named: 'workPlace'),
        workLevel: any(named: 'workLevel'),
      ),
    ).thenAnswer((_) async => right(<JobEntity>[]));
    if (sl.isRegistered<GetJobsUseCase>()) sl.unregister<GetJobsUseCase>();
    sl.registerLazySingleton<GetJobsUseCase>(() => useCase);
  });

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => BlocProvider<JobsBloc>(
      create: (_) => JobsBloc(getJobsUseCase: useCase),
      child: MaterialApp(
        localizationsDelegates: const [AppLocalizationDelegate()],
        supportedLocales: const [Locale('en'), Locale('ar')],
        theme: ThemeData(extensions: const [AppThemeColors.light]),
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => const Scaffold()),
        home: const JobSearchResultsPage(query: 'flutter'),
      ),
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

  group('JobSearchResultsPage', () {
    testWidgets('يعرض نتائج البحث', (tester) async {
      when(
        () => useCase.call(
          search: any(named: 'search'),
          type: any(named: 'type'),
          workPlace: any(named: 'workPlace'),
          workLevel: any(named: 'workLevel'),
        ),
      ).thenAnswer(
        (_) async => right([
          const JobEntity(
            id: 'j1',
            title: 'Flutter Developer',
            companyId: 'c1',
            companyName: 'Tech Co',
            location: 'Cairo',
          ),
        ]),
      );

      await pumpApp(tester);

      expect(find.text('Flutter Developer'), findsOneWidget);
      expect(find.textContaining('Tech Co'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('نتائج فارغة تعرض رسالة', (tester) async {
      await pumpApp(tester);

      expect(find.text('No jobs found for "flutter"'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('الضغط على فلتر يطلب بحثًا جديدًا', (tester) async {
      await pumpApp(tester);

      await tester.tap(find.text('Remote'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      verify(
        () => useCase.call(
          search: any(named: 'search'),
          type: any(named: 'type'),
          workPlace: any(named: 'workPlace'),
          workLevel: any(named: 'workLevel'),
        ),
      ).called(greaterThanOrEqualTo(2));

      await tearDownTree(tester);
    });
  });
}
