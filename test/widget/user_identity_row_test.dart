import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/network/presentation/widgets/user_identity_row.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

Widget _wrap(Widget child) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (context, c) => MaterialApp(
    localizationsDelegates: const [AppLocalizationDelegate()],
    supportedLocales: const [Locale('en'), Locale('ar')],
    theme: ThemeData(extensions: const [AppThemeColors.light]),
    home: Scaffold(body: child),
  ),
);

Future<void> pumpApp(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(widget);
  await tester.pump();
}

void main() {
  group('UserIdentityRow', () {
    testWidgets('يعرض الاسم والعنوان الوظيفي', (tester) async {
      await pumpApp(
        tester,
        _wrap(
          const UserIdentityRow(
            avatarUrl: '',
            name: 'Ahmed Salem',
            headline: 'Flutter Developer',
          ),
        ),
      );

      expect(find.text('Ahmed Salem'), findsOneWidget);
      expect(find.text('Flutter Developer'), findsOneWidget);
    });

    testWidgets('لا يحمل صورة شبكية عند avatar فارغ (أيقونة بدلاً)', (
      tester,
    ) async {
      await pumpApp(
        tester,
        _wrap(const UserIdentityRow(avatarUrl: '', name: 'X', headline: '')),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('يعرض النص الاحتياطي عندما يكون العنوان فارغًا', (
      tester,
    ) async {
      await pumpApp(
        tester,
        _wrap(
          const UserIdentityRow(
            avatarUrl: '',
            name: 'X',
            headline: '',
            headlineFallback: 'Member',
          ),
        ),
      );

      expect(find.text('Member'), findsOneWidget);
    });

    testWidgets('fromUserJson يبني الاسم من الاسم الأول والأخير', (
      tester,
    ) async {
      await pumpApp(
        tester,
        _wrap(
          UserIdentityRow.fromUserJson(const {
            '_id': 'u1',
            'profile': {
              'firstName': 'Sara',
              'lastName': 'Khalid',
              'headline': 'PM',
              'avatar': '',
            },
          }),
        ),
      );

      expect(find.text('Sara Khalid'), findsOneWidget);
      expect(find.text('PM'), findsOneWidget);
    });

    testWidgets('يعرض trailing عند تمريره', (tester) async {
      await pumpApp(
        tester,
        _wrap(
          UserIdentityRow.fromUserJson(const {
            '_id': 'u1',
            'profile': {'firstName': 'S', 'lastName': 'K', 'avatar': ''},
          }, trailing: const Text('BUTTON')),
        ),
      );

      expect(find.text('BUTTON'), findsOneWidget);
    });
  });
}
