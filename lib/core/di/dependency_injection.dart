import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../../api_service.dart';
import '../network/network_info.dart';
import '../network/connectivity_interceptor.dart';
import '../network/retry_interceptor.dart';
import '../presentation/manager/app_settings_cubit.dart';

// Company
import '../../features/company/data/datasources/company_remote_data_source.dart';
import '../../features/company/data/repositories/company_repository_impl.dart';
import '../../features/company/domain/repositories/company_repository.dart';
import '../../features/company/domain/usecases/create_company_usecase.dart';
import '../../features/company/presentation/manager/company_bloc.dart';

// Chat
import '../../features/messages/data/services/chat_rest_service.dart';

// App Theme
import '../presentation/manager/theme_bloc.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/data/services/auth_social_service.dart';

// Jobs
import '../../features/jobs/data/datasources/jobs_remote_data_source.dart';
import '../../features/jobs/data/repositories/jobs_repository_impl.dart';
import '../../features/jobs/domain/repositories/jobs_repository.dart';
import '../../features/jobs/domain/usecases/get_jobs_usecase.dart';
import '../../features/jobs/presentation/manager/jobs_bloc.dart';

// Feed / Posts
import '../../features/feed/data/datasources/post_remote_data_source.dart';
import '../../features/feed/data/repositories/post_repository_impl.dart';
import '../../features/feed/domain/repositories/post_repository.dart';
import '../../features/feed/domain/usecases/get_posts_usecase.dart';
import '../../features/feed/domain/usecases/get_post_usecase.dart';
import '../../features/feed/domain/usecases/create_post_usecase.dart';
import '../../features/feed/domain/usecases/toggle_like_usecase.dart';
import '../../features/feed/presentation/manager/post_bloc.dart';
import '../../features/feed/presentation/manager/post_detail_cubit.dart';
import '../../features/feed/presentation/manager/create_post_cubit.dart';

// Deep Linking
import '../deep_linking/deep_link_service.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // --- Core & External ---
  final sharedPrefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  sl.registerLazySingleton<InternetConnection>(() => InternetConnection());

  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(kIsWeb ? null : sl<InternetConnection>()),
  );

  sl.registerLazySingleton<ConnectivityInterceptor>(
    () => ConnectivityInterceptor(sl<InternetConnection>()),
  );

  sl.registerLazySingleton<RetryInterceptor>(
    () => RetryInterceptor(
      maxRetries: 3,
      retryDelay: const Duration(seconds: 1),
    ),
  );

  sl.registerLazySingleton<ApiService>(() => ApiService(
    connectivityInterceptor: sl<ConnectivityInterceptor>(),
    retryInterceptor: sl<RetryInterceptor>(),
  ));

  sl.registerLazySingleton<AppSettingsCubit>(
    () => AppSettingsCubit(sharedPreferences: sl()),
  );

  // --- Deep Linking ---
  sl.registerLazySingleton<DeepLinkService>(
    () => DeepLinkService(),
  );

  // --- Features: Auth ---
  sl.registerLazySingleton<AuthSocialService>(
    () => AuthSocialService(sl<ApiService>()),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: sl(),
      authRepository: sl(),
      authSocialService: sl(),
    ),
  );

  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      secureStorage: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<ApiService>()),
  );

  // --- Features: Jobs ---
  sl.registerFactory<JobsBloc>(
    () => JobsBloc(getJobsUseCase: sl()),
  );

  sl.registerLazySingleton<GetJobsUseCase>(
    () => GetJobsUseCase(sl()),
  );

  sl.registerLazySingleton<JobsRepository>(
    () => JobsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<JobsRemoteDataSource>(
    () => JobsRemoteDataSourceImpl(sl<ApiService>()),
  );

  // --- Features: Feed / Posts ---
  sl.registerFactory<PostBloc>(
    () => PostBloc(
      getPostsUseCase: sl(),
      toggleLikeUseCase: sl(),
    ),
  );

  sl.registerFactory<CreatePostCubit>(
    () => CreatePostCubit(createPostUseCase: sl()),
  );

  sl.registerLazySingleton<GetPostsUseCase>(() => GetPostsUseCase(sl()));
  sl.registerLazySingleton<GetPostUseCase>(() => GetPostUseCase(sl()));
  sl.registerLazySingleton<CreatePostUseCase>(() => CreatePostUseCase(sl()));
  sl.registerLazySingleton<ToggleLikeUseCase>(() => ToggleLikeUseCase(sl()));

  sl.registerFactory<PostDetailCubit>(
    () => PostDetailCubit(getPostUseCase: sl()),
  );

  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(sl<ApiService>()),
  );

  // --- Features: Company ---
  sl.registerFactory<CompanyBloc>(
    () => CompanyBloc(createCompanyUseCase: sl()),
  );
  sl.registerLazySingleton<CreateCompanyUseCase>(
    () => CreateCompanyUseCase(sl()),
  );
  sl.registerLazySingleton<CompanyRepository>(
    () => CompanyRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  sl.registerLazySingleton<CompanyRemoteDataSource>(
    () => CompanyRemoteDataSourceImpl(sl<ApiService>()),
  );

  // --- Features: Chat REST ---
  sl.registerLazySingleton<ChatRestService>(
    () => ChatRestService(sl<ApiService>()),
  );

  // --- Theme ---
  sl.registerLazySingleton<ThemeBloc>(
    () => ThemeBloc(sharedPreferences: sl()),
  );
}
