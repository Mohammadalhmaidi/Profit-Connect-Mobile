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
import 'package:profit_connect_mobile/features/auth/data/services/auth_social_service.dart';
import 'package:profit_connect_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:profit_connect_mobile/features/auth/domain/usecases/login_usecase.dart';
import 'package:profit_connect_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:profit_connect_mobile/features/feed/domain/entities/post_entity.dart';
import 'package:profit_connect_mobile/features/feed/domain/usecases/get_posts_usecase.dart';
import 'package:profit_connect_mobile/features/feed/domain/usecases/toggle_like_usecase.dart';
import 'package:profit_connect_mobile/features/feed/presentation/manager/post_bloc.dart';
import 'package:profit_connect_mobile/features/feed/presentation/pages/home_page.dart';
import 'package:profit_connect_mobile/features/main_layout/presentation/manager/navigation_cubit.dart';
import 'package:profit_connect_mobile/l10n/app_localizations.dart';

class _MockGetPosts extends Mock implements GetPostsUseCase {}

class _MockToggleLike extends Mock implements ToggleLikeUseCase {}

class _MockAuthRepository extends Mock implements AuthRepository {}

class _MockLoginUseCase extends Mock implements LoginUseCase {}

class _MockAuthSocialService extends Mock implements AuthSocialService {}

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
  late _MockGetPosts getPosts;
  late _MockToggleLike toggleLike;

  setUp(() {
    registerFallbackValue(const GetPostsParams());
    registerFallbackValue('post_id');
    if (sl.isRegistered<ApiService>()) sl.unregister<ApiService>();
    f = _F();
    sl.registerSingleton<ApiService>(f);
    getPosts = _MockGetPosts();
    toggleLike = _MockToggleLike();
    when(() => getPosts.call(any())).thenAnswer(
      (_) async => right(<PostEntity>[
        PostEntity(
          id: 'p1',
          userId: 'u1',
          userName: 'أحمد سالم',
          userRole: 'Developer',
          userAvatar: '',
          content: 'منشور تجريبي',
          createdAt: DateTime(2026),
        ),
      ]),
    );
    when(
      () => toggleLike.call(any()),
    ).thenAnswer((_) async => right<Failure, void>(null));
  });

  Widget buildApp() => ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (c, _) => MaterialApp(
      localizationsDelegates: const [AppLocalizationDelegate()],
      supportedLocales: const [Locale('en'), Locale('ar')],
      theme: ThemeData(extensions: const [AppThemeColors.light]),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<PostBloc>(
            create: (_) => PostBloc(
              getPostsUseCase: getPosts,
              toggleLikeUseCase: toggleLike,
            )..add(const GetPostsEvent()),
          ),
          BlocProvider<AuthBloc>(
            create: (_) => AuthBloc(
              loginUseCase: _MockLoginUseCase(),
              authRepository: _MockAuthRepository(),
              authSocialService: _MockAuthSocialService(),
            ),
          ),
          BlocProvider<NavigationCubit>(create: (_) => NavigationCubit()),
        ],
        child: const HomePage(),
      ),
    ),
  );

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> tearDownTree(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
  }

  group('HomePage', () {
    testWidgets('يعرض المنشورات المحمّلة', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await pumpApp(tester);

      expect(find.text('أحمد سالم'), findsOneWidget);
      expect(find.text('منشور تجريبي'), findsOneWidget);

      await tearDownTree(tester);
    });

    testWidgets('عند فشل الجلب يعرض حالة الخطأ مع زر إعادة المحاولة', (
      tester,
    ) async {
      when(
        () => getPosts.call(any()),
      ).thenAnswer((_) async => left(const ServerFailure('فشل')));

      await pumpApp(tester);

      expect(find.text('Retry'), findsOneWidget);

      await tearDownTree(tester);
    });
  });
}
