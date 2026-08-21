import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:profit_connect_mobile/api_service.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/profile/presentation/pages/followers_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';
import '../helpers/fake_api_service.dart';
import '../helpers/test_utils.dart';

late FakeApiService _fake;

Widget _build(Widget child) => ScreenUtilInit(
  designSize: const Size(375, 812),
  builder: (context, c) => MaterialApp(
    localizationsDelegates: const [AppLocalizationDelegate()],
    supportedLocales: const [Locale('en'), Locale('ar')],
    theme: ThemeData(extensions: const [AppThemeColors.light]),
    home: child,
  ),
);

void main() {
  setUp(() {
    _fake = FakeApiService();
    if (sl.isRegistered<ApiService>()) sl.unregister<ApiService>();
    sl.registerSingleton<ApiService>(_fake);
  });

  group('FollowersPage', () {
    testWidgets('_isSelf لا يعرض أي زر متابعة', (tester) async {
      silenceImageErrors();
      _fake.onGetCurrentUserId = () => 'me';
      _fake.onGetMyFollowing = () => {'data': []};
      _fake.onGetUserFollowers = (_) => {
        'data': [
          userJson('u1', 'فاطمة', 'زهراء'),
          userJson('u2', 'سلمى', 'نور'),
        ],
        'count': 2,
      };

      await tester.pumpWidget(
        _build(const FollowersPage(userId: 'me', mode: 'followers')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('فاطمة زهراء'), findsOneWidget);
      expect(find.text('سلمى نور'), findsOneWidget);
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('عرض مستخدم آخر: أزرار متابعة/متابع مع التبديل', (
      tester,
    ) async {
      silenceImageErrors();
      _fake.onGetCurrentUserId = () => 'me';
      _fake.onGetMyFollowing = () => {
        'data': [
          {'_id': 'u2', 'profile': userJson('u2', 'سلمى', 'نور')['profile']},
        ],
      };
      _fake.onGetUserFollowers = (_) => {
        'data': [
          userJson('u1', 'فاطمة', 'زهراء'),
          userJson('u2', 'سلمى', 'نور'),
        ],
        'count': 2,
      };
      _fake.onGetUserFollowing = (_) => {'data': [], 'count': 0};

      await tester.pumpWidget(
        _build(const FollowersPage(userId: 'other', mode: 'followers')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // زران: غير متابعة (فاطمة) + متابعة بالفعل (سلمى)
      final buttons = find.byType(OutlinedButton);
      expect(buttons, findsNWidgets(2));

      // الضغط على الزر الأول (فاطمة — غير متابعة) → متابعة
      await tester.tap(buttons.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(_fake.followCalls, 1);
      expect(_fake.unfollowCalls, 0);
    });

    testWidgets('التبديل بين قائمة المتابعين وقائمة المتابَعين', (
      tester,
    ) async {
      silenceImageErrors();
      _fake.onGetCurrentUserId = () => 'me';
      _fake.onGetMyFollowing = () => {'data': []};
      _fake.onGetUserFollowers = (_) => {
        'data': [userJson('u1', 'فاطمة', 'زهراء')],
        'count': 1,
      };
      _fake.onGetUserFollowing = (_) => {
        'data': [userJson('uX', 'شخص', 'آخر')],
        'count': 1,
      };

      await tester.pumpWidget(
        _build(const FollowersPage(userId: 'me', mode: 'followers')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('فاطمة زهراء'), findsOneWidget);

      // التبديل إلى المتابَعين — الثواني في الـ header (التابعين > المتابَعين)
      await tester.tap(find.byType(InkWell).at(1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('شخص آخر'), findsOneWidget);
      expect(find.text('فاطمة زهراء'), findsNothing);
    });
  });
}
