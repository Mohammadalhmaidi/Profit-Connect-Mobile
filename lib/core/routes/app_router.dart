import 'package:flutter/material.dart';
import 'app_page_route.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/onboarding/presentation/pages/profile_form_page.dart';
import '../../features/onboarding/presentation/pages/strengths_page.dart';
import '../../features/main_layout/presentation/pages/main_layout_page.dart';
import '../../features/jobs/presentation/pages/jobs_page.dart';
import '../../features/jobs/presentation/pages/my_applications_page.dart';
import '../../features/jobs/presentation/pages/job_details_page.dart';
import '../../features/jobs/presentation/pages/job_search_results_page.dart';
import '../../features/jobs/domain/entities/job_entity.dart';
import '../../features/messages/presentation/pages/messages_page.dart';
import '../../features/messages/presentation/pages/chat_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/change_password_page.dart';
import '../../features/network/presentation/pages/network_page.dart';
import '../../features/network/presentation/pages/search_users_page.dart';
import '../../features/feed/presentation/pages/home_page.dart';
import '../../features/feed/presentation/pages/hashtag_feed_page.dart';
import '../../features/profile/presentation/pages/profile_creation_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart'
    as user_profile;
import '../../features/profile/presentation/pages/followers_page.dart';
import '../../features/company/presentation/pages/company_creation_page.dart';
import '../../features/company/presentation/pages/company_profile_page.dart';
import '../../features/company/presentation/pages/company_dashboard_page.dart';
import '../../features/wallet/presentation/pages/wallet_page.dart';
import '../../features/salaries/presentation/pages/salaries_page.dart';
import '../../features/payments/presentation/pages/payments_page.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/feed/presentation/pages/post_details_page.dart';
import '../../features/feed/presentation/pages/saved_posts_page.dart';
import '../../features/feed/presentation/pages/leaderboard_page.dart';
import '../../features/feed/presentation/pages/portfolio_page.dart';
import '../../features/feed/presentation/pages/portfolio_item_details_page.dart';
import '../../features/settings/presentation/pages/help_support_page.dart';
import '../../features/settings/presentation/pages/about_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String profileForm = '/profile-form';
  static const String strengths = '/strengths';
  static const String mainLayout = '/main';
  static const String home = '/home';
  static const String jobs = '/jobs';
  static const String jobDetails = '/job-details';
  static const String jobSearch = '/job-search';
  static const String myApplications = '/my-applications';
  static const String messages = '/messages';
  static const String chat = '/chat';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String followList = '/follow-list';
  static const String profileCreation = '/profile-creation';
  static const String settings = '/settings';
  static const String changePassword = '/change-password';
  static const String network = '/network';
  static const String searchUsers = '/search-users';
  static const String companyCreation = '/company-creation';
  static const String companyProfile = '/company-profile';
  static const String companyDashboard = '/company-dashboard';
  static const String wallet = '/wallet';
  static const String salaries = '/salaries';
  static const String payments = '/payments';
  static const String projects = '/projects';
  static const String postDetails = '/post-details';
  static const String hashtagFeed = '/hashtag-feed';
  static const String savedPosts = '/saved-posts';
  static const String leaderboard = '/leaderboard';
  static const String portfolio = '/portfolio';
  static const String portfolioItem = '/portfolio-item';
  static const String help = '/help-support';
  static const String about = '/about';

  static final Map<String, String> deepLinkRoutes = {
    'post': postDetails,
    'profile': profile,
    'job': jobDetails,
    'chat': chat,
  };

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return _page(const SplashPage(), routeSettings);
      case login:
        return _page(const LoginPage(), routeSettings);
      case signUp:
        return _page(const SignUpPage(), routeSettings);
      case forgotPassword:
        return _page(const ForgotPasswordPage(), routeSettings);
      case resetPassword:
        return _page(
          ResetPasswordPage(email: routeSettings.arguments as String? ?? ''),
          routeSettings,
        );
      case profileForm:
        return _page(const ProfileFormPage(), routeSettings);
      case strengths:
        return _page(const StrengthsPage(), routeSettings);
      case mainLayout:
        return _page(const MainLayoutPage(), routeSettings);
      case home:
        return _page(const HomePage(), routeSettings);
      case jobs:
        return _page(const JobsPage(), routeSettings);
      case jobDetails:
        final job = routeSettings.arguments is JobEntity
            ? routeSettings.arguments as JobEntity
            : null;
        return _page(JobDetailsPage(job: job), routeSettings);
      case jobSearch:
        return _page(
          JobSearchResultsPage(query: routeSettings.arguments as String? ?? ''),
          routeSettings,
        );
      case myApplications:
        return _page(const MyApplicationsPage(), routeSettings);
      case messages:
        return _page(const MessagesPage(), routeSettings);
      case chat:
        final args = routeSettings.arguments;
        var conversationId = '';
        var userName = 'User';
        var avatar = '';
        if (args is Map) {
          conversationId = args['conversationId'] as String? ?? '';
          userName = args['name'] as String? ?? 'User';
          avatar = args['avatar'] as String? ?? '';
        } else if (args is String) {
          userName = args;
        }
        return _page(
          ChatPage(
            conversationId: conversationId,
            userName: userName,
            peerAvatar: avatar,
          ),
          routeSettings,
        );
      case notifications:
        return _page(const NotificationsPage(), routeSettings);
      case profile:
        return _page(
          user_profile.ProfilePage(userId: routeSettings.arguments as String?),
          routeSettings,
        );
      case followList:
        final args = routeSettings.arguments is Map
            ? routeSettings.arguments as Map
            : <String, dynamic>{};
        return _page(
          FollowersPage(
            userId: args['userId'] as String? ?? '',
            mode: args['mode'] as String? ?? 'followers',
          ),
          routeSettings,
        );
      case profileCreation:
        return _page(const ProfileCreationPage(), routeSettings);
      case settings:
        return _page(const SettingsPage(), routeSettings);
      case changePassword:
        return _page(const ChangePasswordPage(), routeSettings);
      case network:
        return _page(const NetworkPage(), routeSettings);
      case searchUsers:
        return _page(const SearchUsersPage(), routeSettings);
      case companyCreation:
        return _page(const CompanyCreationPage(), routeSettings);
      case companyProfile:
        final companyId = routeSettings.arguments as String?;
        return _page(
          companyId == null
              ? const CompanyCreationPage()
              : CompanyProfilePage(companyId: companyId),
          routeSettings,
        );
      case companyDashboard:
        final dashboardCompanyId = routeSettings.arguments as String?;
        return _page(
          dashboardCompanyId == null
              ? const CompanyCreationPage()
              : CompanyDashboardPage(companyId: dashboardCompanyId),
          routeSettings,
        );
      case wallet:
        return _page(const WalletPage(), routeSettings);
      case salaries:
        return _page(const SalariesPage(), routeSettings);
      case payments:
        return _page(const PaymentsPage(), routeSettings);
      case projects:
        return _page(const ProjectsPage(), routeSettings);
      case postDetails:
        return _page(
          PostDetailsPage(postId: routeSettings.arguments as String? ?? ''),
          routeSettings,
        );
      case hashtagFeed:
        return _page(
          HashtagFeedPage(tag: routeSettings.arguments as String? ?? ''),
          routeSettings,
        );
      case help:
        return _page(const HelpSupportPage(), routeSettings);
      case savedPosts:
        return _page(const SavedPostsPage(), routeSettings);
      case leaderboard:
        return _page(const LeaderboardPage(), routeSettings);
      case portfolio:
        return _page(const PortfolioPage(), routeSettings);
      case portfolioItem:
        return _page(
          PortfolioItemDetailsPage(
            itemId: routeSettings.arguments as String? ?? '',
          ),
          routeSettings,
        );
      case about:
        return _page(const AboutPage(), routeSettings);
      default:
        return _page(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
          routeSettings,
        );
    }
  }

  static Route<dynamic> _page(Widget page, RouteSettings settings) {
    if (settings.name == splash || settings.name == login) {
      return PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      );
    }
    return appPageRoute(page, settings: settings);
  }
}
