import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/feed/presentation/widgets/post_card.dart';
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
  group('PostCard', () {
    testWidgets('يعرض المحتوى مع avatar فارغ دون انهيار', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpApp(
        tester,
        _wrap(
          const PostCard(
            userName: 'Test User',
            userRole: 'Developer',
            userAvatar: '',
            timeAgo: '2h',
            content: 'Hello world',
            hashtags: [],
            likes: '0',
            comments: '0',
            postId: 'p1',
          ),
        ),
      );

      expect(find.text('Test User'), findsOneWidget);
      expect(find.text('Hello world'), findsOneWidget);
      // أيقونة بدل الصورة — لا يوجد طلب شبكة لصورة فارغة
      expect(find.byIcon(Icons.person), findsWidgets);
    });

    testWidgets('عرض مستخدم مع معرف صحيح لا يكسر البناء', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpApp(
        tester,
        _wrap(
          PostCard(
            userName: 'Sara',
            userRole: 'PM',
            userAvatar: 'https://test.example/a.png',
            timeAgo: '1h',
            content: 'Post body',
            hashtags: const [],
            likes: '5',
            comments: '2',
            postId: 'p2',
            userId: 'u2',
            onLike: () {},
          ),
        ),
      );

      expect(find.text('Sara'), findsOneWidget);
      expect(find.text('Post body'), findsOneWidget);
    });
  });
}
