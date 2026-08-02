# Profit Connect Mobile

A professional networking and job platform built with Flutter.

## 🏗️ Architecture

Clean Architecture with BLoC/Cubit state management and GetIt dependency injection.

```
lib/
├── core/                    # Shared core functionality
│   ├── theme/              # Design system (AppTheme)
│   ├── di/                 # Dependency injection
│   ├── routes/             # App routing
│   ├── error/              # Error handling
│   ├── network/            # Network (interceptors, connectivity)
│   ├── image/              # Image optimization helpers
│   ├── deep_linking/       # Deep link handling
│   ├── utils/              # Utilities (validators, helpers)
│   ├── presentation/       # Shared widgets & managers
│   └── api/                # API configuration
├── features/               # Feature modules (Clean Architecture)
│   ├── auth/               # Authentication
│   ├── feed/               # Posts & social feed
│   ├── jobs/               # Job listings & details
│   ├── messages/           # Chat & messaging
│   ├── network/            # Professional network
│   ├── profile/            # User profile
│   ├── companies/          # Company management
│   ├── notifications/      # Notifications
│   └── settings/           # App settings
├── api_service.dart        # Centralized HTTP client
└── main.dart
```

## 🧱 Clean Architecture Layers

Each feature follows:
```
feature/
├── data/
│   ├── datasources/       # Remote/Local data sources
│   ├── models/            # Data models (DTOs)
│   └── repositories/      # Repository implementations
├── domain/
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository contracts
│   └── usecases/          # Business logic
└── presentation/
    ├── managers/          # BLoBs/Cubits
    ├── pages/             # Screens
    └── widgets/           # Reusable widgets
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.44+
- Dart 3.11+
- Android Studio / VS Code
- Git

### Installation

```bash
# Clone repository
git clone <repository-url>
cd profit-connect-mobile

# Install dependencies
flutter pub get

# Copy environment file
cp .env.example .env

# Generate splash screen
flutter pub run flutter_native_splash:create

# Run analysis
make analyze

# Run tests
make test

# Run development build
flutter run
```

## 🛠️ Available Commands

```bash
make analyze      # Static analysis with flutter analyze
make test         # Run tests with coverage
make format       # Format code with dart format
make fix          # Auto-fix issues with dart fix
make clean        # Clean build artifacts
make build-android # Build Android APK
make build-ios    # Build iOS
make build-web    # Build Web
make ci           # Run full CI pipeline
```

## 🧪 Testing

```bash
# Unit tests
flutter test test/unit/

# Widget tests
flutter test test/widget/

# Integration tests
flutter test integration_test/

# All tests with coverage
flutter test --coverage
```

## 📦 Build & Deploy

```bash
# Development
flutter run

# Staging
flutter build apk --release

# Production
flutter build apk --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## ✨ Features

### Network Resilience
- **Connectivity Interceptor** — Blocks requests when offline
- **Retry Interceptor** — Auto-retries on 408/429/500/502/503/504
- **Token Refresh** — Auto-refreshes expired JWT tokens on 401
- **Dio Error Handling** — Centralized error mapping via `handleDioError`

### API
- **Pagination** — Cursor-based and page-based pagination support
- **Token Management** — Secure storage with refresh token support
- **Multipart Uploads** — File upload support for images, documents
- **Environment Config** — `.env` file support via `flutter_dotenv`

### Chat
- **Stream Caching** — TTL-based message caching (2 min)
- **Auto Polling** — 3-second polling interval with cache-first strategy
- **Keep-Alive** — Proper disposal and stream management

### Design System
- **Material 3** — Full Material 3 theming
- **Light & Dark** — Complete dark mode support
- **Responsive** — `flutter_screenutil` for adaptive layouts
- **Consistent** — Unified colors, typography, spacing, shadows

### CI/CD
- **GitHub Actions** — Automated analyze, test, build, deploy
- **Fastlane** — Play Store and App Store deployment
- **Proguard** — Android release obfuscation rules

## 📚 Documentation

- [Architecture Guide](docs/ARCHITECTURE.md)
- [API Reference](docs/API.md)
- [Design System](docs/DESIGN_SYSTEM.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Agent Instructions](AGENTS.md)

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.