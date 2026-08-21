import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:profit_connect_mobile/core/di/dependency_injection.dart';
import 'package:profit_connect_mobile/core/error/failures.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';
import 'package:profit_connect_mobile/features/feed/domain/entities/post_entity.dart';
import 'package:profit_connect_mobile/features/feed/domain/usecases/add_comment_usecase.dart';
import 'package:profit_connect_mobile/features/feed/domain/usecases/get_post_usecase.dart';
import 'package:profit_connect_mobile/features/feed/domain/usecases/toggle_like_usecase.dart';
import 'package:profit_connect_mobile/features/feed/presentation/manager/post_detail_cubit.dart';
import 'package:profit_connect_mobile/features/feed/presentation/pages/post_details_page.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

import '../helpers/test_utils.dart';

class _MockGetPost extends Mock implements GetPostUseCase {}

class _MockAddComment extends Mock implements AddCommentUseCase {}

class _MockToggleLike extends Mock implements ToggleLikeUseCase {}

void main() {
  setUpAll(loadRealFont);

  late _MockGetPost getPost;
  late _MockAddComment addComment;
  late _MockToggleLike toggleLike;

  setUp(() {
    getPost = _MockGetPost();
    addComment = _MockAddComment();
    toggleLike = _MockToggleLike();
    when(() => getPost.call(any())).thenAnswer(
      (_) async => right(
        PostEntity(
          id: 'p1',
          userId: 'u1',
          userName: 'Ahmed Salem',
          userRole: 'JobSeeker',
          userAvatar: '',
          content: 'Post content here',
          createdAt: DateTime(2026),
        ),
      ),
    );
    when(
      () => addComment.call(
        postId: any(named: 'postId'),
        comment: any(named: 'comment'),
      ),
    ).thenAnswer((_) async => right(<String, dynamic>{'success': true}));
    if (sl.isRegistered<PostDetailCubit>()) sl.unregister<PostDetailCubit>();
    sl.registerFactory<PostDetailCubit>(
      () => PostDetailCubit(
        getPostUseCase: getPost,
        addCommentUseCase: addComment,
        toggleLikeUseCase: toggleLike,
      ),
    );
  });

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => MaterialApp(
      localizationsDelegates: const [AppLocalizationDelegate()],
      supportedLocales: const [Locale('en'), Locale('ar')],
      theme: ThemeData(extensions: const [AppThemeColors.light]),
      home: const PostDetailsPage(postId: 'p1'),
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

  group('PostDetailsPage', () {
    testWidgets('يعرض المنشور والتعليقات الفارغة', (tester) async {
      await pumpApp(tester);

      expect(find.text('Post'), findsOneWidget);
      expect(find.text('Post content here'), findsOneWidget);
      expect(find.text('Ahmed Salem'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('خطأ الجلب يعرض رسالة الخطأ', (tester) async {
      when(
        () => getPost.call(any()),
      ).thenAnswer((_) async => left(const ServerFailure('Failed to load')));

      await pumpApp(tester);

      expect(find.text('Failed to load'), findsOneWidget);

      await tearDownTree(tester);
    });
  });
}
