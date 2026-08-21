import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_animation.dart';
import 'core/routes/app_router.dart';
import 'core/di/dependency_injection.dart';
import 'core/network/api_base_url_resolver.dart';
import 'core/presentation/manager/app_settings_cubit.dart';
import 'core/presentation/manager/theme_bloc.dart';
import 'core/utils/bloc_observer.dart';
import 'core/deep_linking/deep_link_service.dart';
import 'core/presentation/widgets/error_boundary.dart';
import 'l10n/app_localizations.dart';
import 'core/services/firebase_messaging_service.dart';
import 'core/services/sentry_service.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/company/presentation/manager/company_bloc.dart';
import 'features/feed/presentation/manager/post_bloc.dart';
import 'features/jobs/presentation/manager/jobs_bloc.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  try {
    await dotenv.load();
  } catch (e) {
    debugPrint('Env load skipped: $e');
  }

  try {
    await ApiBaseUrlResolver.resolve();
    debugPrint('API base URL: ${ApiBaseUrlResolver.current}');
  } catch (e) {
    debugPrint('API base URL resolution skipped: $e');
  }

  Bloc.observer = SimpleBlocObserver();

  try {
    await initDI();
  } catch (e) {
    debugPrint('DI Error: $e');
  }

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  try {
    await SentryService.init();
  } catch (e) {
    debugPrint('Sentry init skipped: $e');
  }

  try {
    await FirebaseMessagingService().initialize();
  } catch (e) {
    debugPrint('Firebase Messaging init skipped: $e');
  }

  runApp(const ProfitApp());
}

class ProfitApp extends StatefulWidget {
  const ProfitApp({super.key});

  @override
  State<ProfitApp> createState() => _ProfitAppState();
}

class _ProfitAppState extends State<ProfitApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
      sl<DeepLinkService>().init(context);
    });
  }

  @override
  void dispose() {
    sl<DeepLinkService>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
    providers: [
      BlocProvider(create: (_) => sl<AuthBloc>()),
      BlocProvider(create: (_) => sl<AppSettingsCubit>()),
      BlocProvider(create: (_) => sl<ThemeBloc>()),
      BlocProvider(create: (_) => sl<PostBloc>()),
      BlocProvider(create: (_) => sl<JobsBloc>()),
      BlocProvider(create: (_) => sl<CompanyBloc>()),
    ],
    child: const _AppRoot(),
  );
}

class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<AppSettingsCubit, AppSettingsState>(
        builder: (context, settingsState) => BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) => ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => MaterialApp(
              debugShowCheckedModeBanner: false,
              navigatorKey: appNavigatorKey,
              onGenerateTitle: (context) =>
                  AppLocalizations.of(context)?.appName ?? 'Profit Connect',
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeState.themeMode,
              locale: settingsState.locale,
              supportedLocales: const [Locale('en', ''), Locale('ar', '')],
              localizationsDelegates: const [
                AppLocalizationDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              initialRoute: AppRouter.splash,
              onGenerateRoute: AppRouter.generateRoute,
              builder: (context, child) =>
                  ErrorBoundary(child: AnimatedThemeSwitcher(child: child!)),
            ),
          ),
        ),
      );
}
