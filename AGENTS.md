# AGENTS.md — Agent Instructions for Profit Connect Mobile

## Project Overview
Profit Connect Mobile is a Flutter application for professional networking and job search.

## Tech Stack
- **Framework**: Flutter 3.22+
- **State Management**: flutter_bloc (BLoC/Cubit)
- **DI**: GetIt
- **Networking**: Dio
- **Local Storage**: flutter_secure_storage, shared_preferences
- **Routing**: Custom AppRouter (named routes)
- **UI**: Material 3, flutter_screenutil

## Key Directories
- `lib/core/` — Shared theme, DI, routes, error handling, utilities
- `lib/features/` — Feature modules (auth, feed, jobs, messages, etc.)
- `lib/api_service.dart` — Centralized HTTP client
- `lib/main.dart` — App entry point with all providers

## Coding Conventions
- **Files**: snake_case (`my_file.dart`)
- **Classes**: PascalCase (`MyClass`)
- **Variables/Functions**: camelCase (`myVariable`, `myFunction`)
- **Constants**: SCREAMING_SNAKE_CASE (`MAX_WIDTH`)
- **BLoC Events**: PascalCase with Event suffix (`GetPostsEvent`)
- **BLoC States**: PascalCase with State suffix (`PostsLoaded`)
- **Cubits**: PascalCase with Cubit suffix (`CreatePostCubit`)

## Architecture Rules
1. Domain layer has ZERO Flutter dependencies
2. Data layer implements Domain interfaces
3. Presentation layer consumes Domain UseCases
4. Never import Data layer in Presentation directly
5. All API calls go through ApiService
6. All errors handled via Failure pattern (dartz)
7. State management via BLoC/Cubit only (no setState in features)

## Testing
- Unit tests: `test/unit/`
- Widget tests: `test/widget/`
- Integration tests: `integration_test/`
- Target coverage: ≥80% for UseCases and Repositories
- Run: `flutter test --coverage`

## Common Commands
```bash
make analyze      # Static analysis
make test         # Run tests
make format       # Format code
make fix          # Auto-fix
make clean        # Clean build
```

## Backend API
- Backend: Node.js/Express at `profit-connect-backend/`
- Default API URL: `http://10.0.2.2:5000` (Android emulator)
- Endpoints: `/api/auth`, `/api/user`, `/api/posts`, `/api/jobs`, `/api/messages`, `/api/companies`, `/api/projects`, `/api/translate`
- No WebSocket — Chat uses REST polling (3s interval)
- Auto token refresh on 401 responses

## Known Issues
- `flutter analyze` requires Flutter SDK installed
- API_BASE_URL must be configured for each environment
- `verify_identity_sheet.dart` was removed (dead route)

## Important Notes
- `withValues(alpha: 0.5)` used in some widgets (Flutter 3.27+ API)
- `sign_in_with_linkedin` and `google_sign_in` packages used for auth
- `PostBloc` no longer has CreatePostEvent (moved to CreatePostCubit)
- `ChatRestService` is a lazy singleton in DI
- `IndexedStack` used in main_layout for keep-alive tabs
- `flutter_dotenv` used for environment variable management
- `SentryService.init()` called in main() for error tracking
- `FirebaseMessagingService().initialize()` called in main() for push notifications
- `AppUpdateChecker().checkForUpdate()` called in main() for version checking
- `ErrorBoundary` wraps the entire app for global error handling
- `AnimatedThemeSwitcher` provides smooth theme transitions
- Deep links handled by `DeepLinkService` with routes: post, profile, job, chat