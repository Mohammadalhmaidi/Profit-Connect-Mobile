import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SentryService {
  static final SentryService _instance = SentryService._internal();
  factory SentryService() => _instance;
  SentryService._internal();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await SentryFlutter.init((options) {
      options.dsn = dotenv.env['SENTRY_DSN'];
      options.tracesSampleRate = 0.1;
      options.debug = !kReleaseMode;
      options.attachThreads = true;
      options.attachStacktrace = true;
      options.sendDefaultPii = false;
    }, appRunner: () {});

    _initialized = true;
  }

  static Future<void> init() async => _instance.initialize();

  Future<void> captureException(
    Object? exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) async {
    if (!_initialized) return;
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: extra != null
          ? (scope) {
              extra.forEach((key, value) {
                scope.setContexts(key, value);
              });
            }
          : null,
    );
  }

  Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
  }) async {
    if (!_initialized) return;
    await Sentry.captureMessage(message, level: level);
  }

  Future<void> addBreadcrumb(Breadcrumb breadcrumb) async {
    if (!_initialized) return;
    Sentry.addBreadcrumb(breadcrumb);
  }

  Future<void> close() async {
    await Sentry.close();
    _initialized = false;
  }
}
