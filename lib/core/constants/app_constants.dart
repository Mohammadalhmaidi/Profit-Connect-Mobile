class AppConstants {
  // App Identity
  static const String appName = 'Profit Connect';
  static const String appVersion = '1.0.0+1';
  static const String packageName = 'com.profitconnect.mobile';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'is_dark_mode';

  // Assets Paths
  static const String logoSvg = 'assets/images/logo.svg';
  static const String successAnimation = 'assets/animations/success.json';
  static const String errorAnimation = 'assets/animations/error.json';

  // Validation Messages
  static const String emailRequired = 'Email address is required';
  static const String invalidEmail = 'Enter a valid email address';
  static const String passwordRequired = 'Password is required';
  static const String passwordShort = 'Password must be at least 8 characters';

  // Generic Feedback
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'No internet connection. Please check your settings.';

  // API
  static const int apiTimeoutSeconds = 15;
  static const int apiMaxRetries = 3;
  static const int apiRetryDelaySeconds = 1;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 50;
  static const int chatPollingIntervalSeconds = 3;
  static const int chatCacheTTLMinutes = 2;

  // Search
  static const int searchDebounceMilliseconds = 300;

  // Image Optimization
  static const int imageMaxWidthCache = 1024;
  static const int imageMaxHeightCache = 1024;
  static const int imageMaxWidthDisk = 1920;
  static const int imageMaxHeightDisk = 1920;
  static const int imageDefaultQuality = 80;

  // Deep Linking
  static const String deepLinkScheme = 'profitconnect';
  static const String deepLinkHost = 'app.profitconnect.com';

  // Cache
  static const int cacheMaxAgeMinutes = 2;
}
