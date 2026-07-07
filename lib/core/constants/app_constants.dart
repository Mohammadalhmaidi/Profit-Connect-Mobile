class AppConstants {
  // App Identity
  static const String appName = 'CareerPath';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = 'https://api.careerpath.com/v1';
  static const String loginEndpoint = '/auth/login';
  static const String signUpEndpoint = '/auth/signup';
  static const String jobsEndpoint = '/jobs';

  // Assets Paths
  static const String logoSvg = 'assets/images/logo.svg';
  static const String successAnimation = 'assets/animations/success.json';
  static const String errorAnimation = 'assets/animations/error.json';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'is_dark_mode';

  // Validation Messages
  static const String emailRequired = 'Email address is required';
  static const String invalidEmail = 'Enter a valid email address';
  static const String passwordRequired = 'Password is required';
  static const String passwordShort = 'Password must be at least 8 characters';
  
  // Generic Feedback
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection. Please check your settings.';
}
