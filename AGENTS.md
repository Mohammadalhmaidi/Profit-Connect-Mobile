# AGENTS.md — Agent Instructions for Profit Connect Mobile

## Project Overview
Profit Connect Mobile is a Flutter application for professional networking and job search.

## Tech Stack
- **Framework**: Flutter 3.44+
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
- Target coverage: ≥80% for UseCases and Repositories (current: UseCases ~95%, Repositories impl ~92%)
- Run: `flutter test --coverage`
- Widget test conventions:
  - Call `loadRealFont()` from `test/helpers/test_utils.dart` in `setUpAll` before pumping any page — flutter_test's default Ahem font (square glyphs ~2x width) causes false RenderFlex overflows
  - Use a tall viewport for scrollable forms: `tester.view.physicalSize = Size(1080, 9000); devicePixelRatio = 3.0` (360x3000 logical) so long forms need no scrolling (buttons stay tappable)
  - After `pumpWidget`, pump ~400ms to let the initial MaterialPageRoute transition finish (Overlay absorbs taps during it)
  - `silenceImageErrors()` for pages rendering network images
  - For pages with flutter_animate/StaggerEntrance zero-duration timers, end tests by pumping a `SizedBox()` to dispose the tree
  - Override `ApiService` with a fake subclass + register via `sl.registerSingleton` (never `sl.reset()`)

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
- API URL: auto-detected at startup by `ApiBaseUrlResolver` (probes 10.0.2.2/10.0.3.2/172.16.1.2 emulator gateways + LAN gateway/same-subnet hosts); override via `API_BASE_URL` in `.env` or with `--dart-define=API_BASE_URL=http://<host-ip>:5000` when building
- Endpoints: `/api/auth`, `/api/user`, `/api/posts`, `/api/jobs`, `/api/messages`, `/api/companies`, `/api/projects`, `/api/translate`
- No WebSocket — Chat uses REST polling (3s interval)
- Auto token refresh on 401 responses

## Known Issues
- `flutter analyze` requires Flutter SDK installed
- `verify_identity_sheet.dart` was removed (dead route)

## Important Notes
- `withValues(alpha: 0.5)` used in some widgets (Flutter 3.27+ API)
- `google_sign_in` package used for auth
- `PostBloc` no longer has CreatePostEvent (moved to CreatePostCubit)
- `ChatRestService` is registered as a factory in DI (fresh instance per access)
- Auth endpoints are rate-limited on the backend: `authLimiter` (20 req/15 min) and `signupLimiter` (10 req/hour); the limiter skips when `NODE_ENV === 'test'` (read live per request)
- `IndexedStack` used in main_layout for keep-alive tabs
- `flutter_dotenv` used for environment variable management
- `SentryService.init()` called in main() for error tracking
- `FirebaseMessagingService().initialize()` called in main() for push notifications
- `AppUpdateChecker().checkForUpdate()` called in main() for version checking
- `ErrorBoundary` wraps the entire app for global error handling (a real StatefulWidget that swaps `ErrorWidget.builder`; note its type is `ErrorWidgetBuilder`, NOT `WidgetBuilder`)
- `AnimatedThemeSwitcher` provides smooth theme transitions
- Deep links handled by `DeepLinkService` with routes: post, profile, job, chat

## Session-Conventions (Batch C/D)
- Auth/401 handling: `ApiService` serializes concurrent refreshes via `Future<bool>? _refreshingFuture`; on refresh failure tokens are cleared with `_clearTokens()`; `logout()` also uses `_clearTokens()`. `RetryInterceptor` honors the `Retry-After` header (clamped to 30s; use `diff > Duration.zero`, not `Duration.isPositive`).
- Pull-to-refresh must NOT flash a skeleton: `PostBloc` keeps the current `PostsLoaded` list while refreshing and exposes `Future<void> refresh()` so `RefreshIndicator.onRefresh` awaits the real fetch. Local pages (e.g. `hashtag_feed_page`) keep the list via `_isLoading && _posts.isEmpty` guard.
- `ApiService.getPosts({hashtag})` filters posts server-side; backend `postController.getPosts` strips a leading `#` into `filter.hashtags`. Route: `AppRouter.hashtagFeed = '/hashtag-feed'`.
- Notifications: `NotificationsPage` marks all as read on `dispose` (`unawaited(...)`), not in the cubit after fetch.
- `wallet_page` shows an escrow ("held") section: `getMyPayments(status: 'held')` + `getCurrentUserId()`; wrap the latter in try/catch and stub it in widget-test fakes (secure storage throws `MissingPluginException` in tests). Add `getMyPayments`/`getCurrentUserId` overrides to fake `ApiService` subclasses.
- l10n: single `context.tr(key, [args])` map in `lib/l10n/app_localizations.dart` (en + ar sections). Always import `l10n/app_localizations.dart` where `tr` is used. Keep the map lean — unused keys are dead code and were removed (171 keys).
- Backend logging: NEVER log a raw `error.message` from OpenAI/fetch — it embeds the API key on 401. Use `sanitizeError()` from `src/utils/sanitizeError.js` (redacts `sk-[A-Za-z0-9_-]{8,}`) everywhere before logging — it is applied across ALL controllers/services/middleware/routes and the global error handler in `index.js` (which also returns sanitized messages to clients). No `console.log` of `req.body`/reset codes/credentials in code (the password-reset `demoCode` console.log is intentionally gated behind `NODE_ENV !== 'production'`).
- MongoDB `$regex`/`RegExp` filters: NEVER interpolate raw user query params — use `escapeRegex()` from `src/utils/regex.js` (applied in admin/company/job/project/salary/network controllers).
- Email validation: use the shared `Validators.email` regex (requires a domain dot + 2+ char TLD); don't inline loose regexes in pages.