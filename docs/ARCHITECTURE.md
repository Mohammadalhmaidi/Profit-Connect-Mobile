# Architecture Guide

## Overview

Profit Connect Mobile follows **Clean Architecture** principles with a **feature-first** organization. The app is built with Flutter using BLoC/Cubit for state management and GetIt for dependency injection.

## 📁 Project Structure

```
lib/
├── core/                          # Shared core functionality
│   ├── theme/                     # Design system (AppTheme)
│   ├── di/                        # Dependency injection (GetIt)
│   ├── routes/                    # App routing
│   ├── error/                     # Error handling (Failures, Exceptions)
│   ├── network/                   # Network (interceptors, connectivity)
│   ├── image/                     # Image optimization helpers
│   ├── deep_linking/              # Deep link handling
│   ├── services/                  # Firebase, Sentry, Update checker
│   ├── l10n/                      # Localization
│   ├── utils/                     # Utilities (validators, helpers, logger)
│   ├── presentation/              # Shared widgets & managers
│   │   ├── manager/               # Shared Cubits (Theme, AppSettings)
│   │   └── widgets/               # Reusable widgets
│   └── api/                       # API configuration (Dio, Interceptors)
├── features/                      # Feature modules (Clean Architecture)
│   ├── auth/                      # Authentication
│   ├── feed/                      # Posts & social feed
│   ├── jobs/                      # Job listings & details
│   ├── messages/                  # Chat & messaging
│   ├── network/                   # Professional network
│   ├── profile/                   # User profile
│   ├── companies/                 # Company management
│   ├── notifications/             # Notifications
│   └── settings/                  # App settings
├── l10n/                          # Localization files
└── main.dart                      # App entry point
```

## 🏛️ Clean Architecture Layers

Each feature follows three layers:

### Domain Layer (Pure Dart)
```
domain/
├── entities/          # Business objects (UserEntity, JobEntity, PostEntity)
├── repositories/      # Repository contracts (abstract classes)
└── usecases/          # Business logic (GetJobsUseCase, CreatePostUseCase)
```
- **No Flutter dependencies**
- Contains business rules and logic
- Independent of frameworks

### Data Layer
```
data/
├── datasources/       # Remote (API) & Local (Cache/DB) implementations
├── models/            # DTOs with fromJson/toJson
└── repositories/      # Repository implementations
```
- Implements repository contracts
- Handles data fetching/caching
- Converts between DTOs and Entities

### Presentation Layer
```
presentation/
├── managers/          # BLoCs/Cubits (state management)
├── pages/             # Screens (Widgets)
└── widgets/           # Reusable UI components
```
- Flutter-dependent
- Consumes UseCases via BLoC/Cubit
- Renders UI and handles user input

## 🔄 Dependency Rule

```
Presentation → Domain ← Data
```

- Domain has **zero dependencies** on other layers
- Data depends on Domain (implements interfaces)
- Presentation depends on Domain (uses UseCases)
- **Never** import Data in Presentation directly

## 🔧 Key Technologies

| Purpose | Technology |
|---------|------------|
| State Management | flutter_bloc (BLoC/Cubit) |
| Dependency Injection | GetIt |
| Networking | Dio |
| Local Storage | flutter_secure_storage, shared_preferences |
| Navigation | Custom Router (AppRouter) |
| Image Loading | cached_network_image |
| Localization | intl, flutter_localizations |
| Testing | bloc_test, mocktail, flutter_test |

## 🔌 Dependency Injection

All dependencies registered in `core/di/dependency_injection.dart`:

```dart
// Features
sl.registerFactory<AuthBloc>(() => AuthBloc(authRepository: sl()));
sl.registerFactory<PostBloc>(() => PostBloc(getPostsUseCase: sl()));

// UseCases
sl.registerLazySingleton<GetPostsUseCase>(() => GetPostsUseCase(sl()));

// Repositories
sl.registerLazySingleton<PostRepository>(() => PostRepositoryImpl(sl(), sl()));

// Data Sources
sl.registerLazySingleton<PostRemoteDataSource>(() => PostRemoteDataSourceImpl(sl()));

// Core
sl.registerLazySingleton<ApiService>(() => ApiService());
sl.registerLazySingleton<SharedPreferences>(() => SharedPreferences.getInstance());
```

## 🌐 API Layer

`lib/api_service.dart` - Centralized HTTP client:
- Dio instance with interceptors
- Auth token management
- Error handling
- Base URL from environment

```dart
final dio = Dio(BaseOptions(
  baseUrl: ApiService.baseUrl,
  connectTimeout: 10s,
  receiveTimeout: 10s,
));

// Interceptor adds Bearer token
// Interceptor handles errors via handleDioError
```

## 🧭 Navigation

`core/routes/app_router.dart` - Centralized routing:
- Named routes with arguments
- Route guards (auth, permissions)
- Deep linking support

```dart
static const String jobDetails = '/job-details';

case jobDetails:
  final job = routeSettings.arguments as JobEntity?;
  return MaterialPageRoute(builder: (_) => JobDetailsPage(job: job));
```

## 🎨 Design System

`core/theme/app_theme.dart` - Centralized theming:
- Colors, TextStyles, Spacing, Shadows
- Light/Dark themes
- Component themes (Button, Input, Card, etc.)

## 🧪 Testing Strategy

| Layer | Tool | Coverage Target |
|-------|------|-----------------|
| Unit (UseCases, Repositories) | bloc_test, mocktail | ≥80% |
| Widget (Pages, Widgets) | flutter_test | Key flows |
| Integration | integration_test | Critical paths |

## 🚀 Build Flavors

| Flavor | Environment | API URL |
|--------|-------------|---------|
| Development | Local/Dev | http://10.0.2.2:5000 |
| Staging | Staging Server | https://staging.api.profitconnect.app |
| Production | Production | https://api.profitconnect.app |

Run with: `flutter run --flavor development`

## 📦 Build & Release

```bash
# Android
flutter build apk --release --flavor production

# iOS
flutter build ios --release --flavor production

# Web
flutter build web --release
```

## 📊 Monitoring

- **Crashlytics**: Crash reporting
- **Firebase Analytics**: User behavior
- **Firebase Performance**: App performance
- **Sentry**: Error tracking (optional)

## 🔐 Security

- API tokens in FlutterSecureStorage
- Certificate pinning (production)
- Network security config (Android)
- ATS configuration (iOS)
- No secrets in code (.env files ignored)

## 📚 Related Documentation

- [API Reference](API.md)
- [Design System](DESIGN_SYSTEM.md)
- [Contributing Guide](../CONTRIBUTING.md)