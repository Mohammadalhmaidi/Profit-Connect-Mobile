import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:profit_connect_mobile/core/theme/app_theme.dart';
import 'package:profit_connect_mobile/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:profit_connect_mobile/features/auth/domain/entities/user_entity.dart';
import 'package:profit_connect_mobile/features/jobs/domain/entities/job_entity.dart';
import 'package:profit_connect_mobile/features/feed/domain/entities/post_entity.dart';

/// Template for widget tests
/// Copy this file and rename for each widget test

/// Mock classes
class MockAuthBloc extends MockBloc<AuthState> implements AuthBloc {}

/// Base widget test setup with theme support
Widget createTestWidget({
  required Widget child,
  List<BlocProvider> providers = const [],
  bool darkMode = false,
}) {
  return MaterialApp(
    theme: darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
    home: MultiBlocProvider(
      providers: providers,
      child: Scaffold(body: child),
    ),
  );
}

/// Common test helpers
extension WidgetTesterHelpers on WidgetTester {
  Future<void> pumpAndSettleWithDelay({Duration duration = const Duration(milliseconds: 500)}) async {
    await pump(duration);
    await pumpAndSettle();
  }

  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }

  /// Simulate a slow network by pumping with a delay
  Future<void> simulateSlowNetwork(Duration delay) async {
    await pump(delay);
  }

  /// Pump the widget and verify it renders without errors
  Future<void> pumpAndVerify({
    required Widget widget,
    Duration duration = const Duration(milliseconds: 100),
  }) async {
    await pumpWidget(widget);
    await pump(duration);
  }
}

/// Common finders
final isLoadingIndicator = find.byType(CircularProgressIndicator);

/// Test data builders
class TestDataBuilder {
  static UserEntity user({
    String id = '1',
    String email = 'test@example.com',
    String fullName = 'Test User',
    String headline = 'Developer',
    String bio = 'Test bio',
    String avatar = '',
    List<String> skills = const ['Flutter', 'Dart'],
  }) {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
      firstName: 'Test',
      lastName: 'User',
      role: UserRole.JobSeeker,
      skills: skills,
      avatar: avatar,
      headline: headline,
      bio: bio,
    );
  }

  static JobEntity job({
    String id = '1',
    String title = 'Flutter Developer',
    String companyName = 'Tech Corp',
    String location = 'Remote',
    double minSalary = 80000,
    double maxSalary = 120000,
  }) {
    return JobEntity(
      id: id,
      title: title,
      description: 'Job description',
      companyId: '1',
      companyName: companyName,
      companyLogo: '',
      location: location,
      salary: SalaryRange(min: minSalary, max: maxSalary, currency: 'USD'),
      type: 'Full-time',
      workLevel: 'Senior',
      workPlace: 'Remote',
      requirements: ['Flutter', 'Dart'],
      responsibilities: ['Build apps'],
      status: 'Open',
      postedById: '1',
    );
  }

  static PostEntity post({
    String id = '1',
    String content = 'Test post content',
    String userName = 'Test User',
    String userRole = 'Developer',
  }) {
    return PostEntity(
      id: id,
      userId: '1',
      userName: userName,
      userRole: userRole,
      userAvatar: '',
      content: content,
      hashtags: ['flutter', 'dart'],
      mediaUrl: null,
      videoUrl: null,
      likesCount: 10,
      commentsCount: 5,
      isLiked: false,
      createdAt: DateTime.now(),
    );
  }
}

/// Error boundary widget for testing
class TestErrorBoundary extends StatelessWidget {
  final Widget child;
  final Widget Function(BuildContext context, FlutterErrorDetails details)?
      errorBuilder;

  const TestErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
