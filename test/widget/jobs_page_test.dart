import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/error/failures.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/jobs/domain/entities/job_entity.dart';
import 'package:profit_connect_mobile/features/jobs/domain/usecases/get_jobs_usecase.dart';
import 'package:profit_connect_mobile/features/jobs/presentation/manager/jobs_bloc.dart';
import 'package:profit_connect_mobile/features/jobs/presentation/pages/jobs_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _MockGetJobs extends Mock implements GetJobsUseCase {}

class _F extends ApiService {
  Response _r(Map<String, dynamic> d) => Response(
    requestOptions: RequestOptions(path: '/'),
    statusCode: 200,
    data: d,
  );

  @override
  Future<Response> getNotifications() async =>
      _r({'data': <Map<String, dynamic>>[]});
}

void main() {
  late _F f;
  late _MockGetJobs useCase;

  setUp(() {
    if (sl.isRegistered<ApiService>()) sl.unregister<ApiService>();
    f = _F();
    sl.registerSingleton<ApiService>(f);
    useCase = _MockGetJobs();
    when(
      () => useCase.call(
        search: any(named: 'search'),
        type: any(named: 'type'),
        workPlace: any(named: 'workPlace'),
        workLevel: any(named: 'workLevel'),
      ),
    ).thenAnswer(
      (_) async => right(<JobEntity>[
        const JobEntity(
          id: 'j1',
          title: 'Flutter Developer',
          companyId: 'c1',
          companyName: 'Tech Co',
          location: 'Cairo',
          salary: SalaryRange(min: 2000, max: 4000),
        ),
        const JobEntity(
          id: 'j2',
          title: 'UI Designer',
          companyId: 'c2',
          companyName: 'Design Studio',
          location: 'Riyadh',
          salary: SalaryRange(min: 1500, max: 2500),
          type: 'Remote',
          workPlace: 'Remote',
        ),
      ]),
    );
  });

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => MaterialApp(
      localizationsDelegates: const [AppLocalizationDelegate()],
      supportedLocales: const [Locale('en'), Locale('ar')],
      theme: ThemeData(extensions: const [AppThemeColors.light]),
      home: BlocProvider<JobsBloc>(
        create: (_) =>
            JobsBloc(getJobsUseCase: useCase)..add(const GetJobsEvent()),
        child: const JobsPage(),
      ),
    ),
  );

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> tearDownTree(WidgetTester tester) async {
    // ترك إطار واحد لتصفية مؤقّتات flutter_animate الصفرية ثم إزالة الشجرة
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  group('JobsPage', () {
    testWidgets('يعرض الوظائف المحمّلة مع أسماء الشركات والرواتب', (
      tester,
    ) async {
      silenceImageErrors();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpApp(tester);

      expect(find.text('Flutter Developer'), findsWidgets);
      expect(find.text('UI Designer'), findsWidgets);
      expect(find.textContaining('Tech Co'), findsWidgets);
      expect(find.textContaining('2000'), findsWidgets);

      await tearDownTree(tester);
    });

    testWidgets('عند فشل الجلب يعرض SnackBar بالخطأ', (tester) async {
      when(
        () => useCase.call(
          search: any(named: 'search'),
          type: any(named: 'type'),
          workPlace: any(named: 'workPlace'),
          workLevel: any(named: 'workLevel'),
        ),
      ).thenAnswer((_) async => left(const ServerFailure('فشل التحميل')));

      await pumpApp(tester);

      expect(find.text('فشل التحميل'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('الفلترة حسب Remote تعرض الوظائف البعيدة فقط', (tester) async {
      silenceImageErrors();
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpApp(tester);

      await tester.tap(find.text('Remote').first);
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Showing Remote Jobs'), findsOneWidget);
      expect(find.text('UI Designer'), findsWidgets);
      expect(find.text('Flutter Developer'), findsNothing);

      await tearDownTree(tester);
    });
  });
}
