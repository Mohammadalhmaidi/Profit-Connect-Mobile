import 'package:flutter/material.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/verify_identity_sheet.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/profile_form_page.dart';
import '../../features/onboarding/presentation/pages/strengths_page.dart';
import '../../features/main_layout/presentation/pages/main_layout_page.dart';
import '../../features/jobs/presentation/pages/jobs_page.dart';
import '../../features/jobs/presentation/pages/job_details_page.dart';
import '../../features/jobs/presentation/pages/job_search_results_page.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/messages/presentation/pages/chat_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/social/presentation/pages/profile_page.dart';
import '../../features/social/presentation/pages/main_nav_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/network/presentation/pages/network_page.dart';
import '../../features/feed/presentation/pages/home_page.dart';
import '../../features/profile/presentation/pages/profile_creation_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart' as user_profile;

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String verifyIdentity = '/verify-identity';
  static const String profileForm = '/profile-form';
  static const String strengths = '/strengths';
  static const String mainLayout = '/main';
  static const String home = '/home';
  static const String jobs = '/jobs';
  static const String jobDetails = '/job-details';
  static const String jobSearch = '/job-search';
  static const String messages = '/messages';
  static const String chat = '/chat';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String profileCreation = '/profile-creation';
  static const String settings = '/settings';
  static const String network = '/network';
  static const String mainNav = '/main-nav';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      case verifyIdentity:
        return MaterialPageRoute(builder: (_) => const VerifyIdentitySheet());
      case profileForm:
        return MaterialPageRoute(builder: (_) => const ProfileFormPage());
      case strengths:
        return MaterialPageRoute(builder: (_) => const StrengthsPage());
      case mainLayout:
        return MaterialPageRoute(builder: (_) => const MainLayoutPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case jobs:
        return MaterialPageRoute(builder: (_) => const JobsPage());
      case jobDetails:
        return MaterialPageRoute(builder: (_) => const JobDetailsPage());
      case jobSearch:
        return MaterialPageRoute(builder: (_) => const JobSearchResultsPage());
      case messages:
        return MaterialPageRoute(builder: (_) => const MessagesPage());
      case chat:
        final userName = routeSettings.arguments as String? ?? "User";
        return MaterialPageRoute(builder: (_) => ChatPage(userName: userName));
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
      case profile:
        final userName = routeSettings.arguments as String?;
        return MaterialPageRoute(builder: (_) => user_profile.ProfilePage(userName: userName));
      case profileCreation:
        return MaterialPageRoute(builder: (_) => const ProfileCreationPage());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case network:
        return MaterialPageRoute(builder: (_) => const NetworkPage());
      case mainNav:
        return MaterialPageRoute(builder: (_) => const MainNavPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
