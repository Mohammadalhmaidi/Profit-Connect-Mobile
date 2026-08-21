import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:profit_connect_mobile/core/error/failures.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/company/domain/entities/company_entity.dart';
import 'package:profit_connect_mobile/features/company/domain/usecases/create_company_usecase.dart';
import 'package:profit_connect_mobile/features/company/presentation/manager/company_bloc.dart';
import 'package:profit_connect_mobile/features/company/presentation/pages/company_creation_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _MockCreateCompany extends Mock implements CreateCompanyUseCase {}

void main() {
  setUpAll(loadRealFont);

  late _MockCreateCompany useCase;

  setUp(() {
    registerFallbackValue(const CreateCompanyParams(name: 'x'));
    useCase = _MockCreateCompany();
    when(() => useCase.call(any())).thenAnswer(
      (_) async => right(const CompanyEntity(id: 'c1', name: 'Tech Co')),
    );
  });

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => MultiBlocProvider(
      providers: [
        BlocProvider<CompanyBloc>(
          create: (_) => CompanyBloc(createCompanyUseCase: useCase),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: const [AppLocalizationDelegate()],
        supportedLocales: const [Locale('en'), Locale('ar')],
        theme: ThemeData(extensions: const [AppThemeColors.light]),
        onGenerateRoute: (settings) =>
            MaterialPageRoute(builder: (_) => const Scaffold()),
        home: const CompanyCreationPage(),
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

  Finder submitBtn() => find.widgetWithText(ElevatedButton, 'Create Company');

  group('CompanyCreationPage', () {
    testWidgets('يعرض نموذج إنشاء الشركة', (tester) async {
      await pumpApp(tester);

      expect(find.text('Create Company'), findsWidgets);
      expect(find.byType(TextFormField), findsAtLeast(4));
      expect(find.text('Company Name'), findsOneWidget);
    });

    testWidgets('اسم فارغ يظهر رسالة حقل مطلوب', (tester) async {
      await pumpApp(tester);

      await tester.tap(submitBtn());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Required'), findsOneWidget);
    });

    testWidgets('إرسال صالح يستدعي createCompany', (tester) async {
      await pumpApp(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Tech Co');
      await tester.enterText(fields.at(1), 'We build software');
      await tester.enterText(fields.at(2), 'https://techco.com');
      await tester.enterText(fields.at(3), 'Cairo, Egypt');
      await tester.tap(submitBtn());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      verify(() => useCase.call(any())).called(1);
    });

    testWidgets('فشل الإنشاء يعرض رسالة خطأ', (tester) async {
      when(
        () => useCase.call(any()),
      ).thenAnswer((_) async => left(const ServerFailure('Failed to create')));

      await pumpApp(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Tech Co');
      await tester.enterText(fields.at(1), 'We build software');
      await tester.enterText(fields.at(2), 'https://techco.com');
      await tester.enterText(fields.at(3), 'Cairo, Egypt');
      await tester.tap(submitBtn());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Failed to create'), findsOneWidget);
    });
  });
}
