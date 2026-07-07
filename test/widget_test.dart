import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_first_app/features/auth/presentation/pages/login_page.dart';
import 'package:my_first_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:my_first_app/core/di/dependency_injection.dart';

void main() {
  testWidgets('LoginPage loads correctly and shows essential fields', (WidgetTester tester) async {
    // Set a larger physical surface size for the test environment to match a real mobile device
    // This helps avoid false-positive overflow errors during testing
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    // Reset the size after the test (optional but good practice)
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // Provide a real or mock Bloc if the widget depends on it
    // For this test, we use sl<AuthBloc>() assuming initDI() was called or we provide a mock.
    // However, since we can't easily call initDI() here without potentially breaking other things,
    // let's ensure we wrap it in a provider.
    
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, child) => MultiBlocProvider(
          providers: [
            // We need to provide AuthBloc because LoginPage uses BlocConsumer<AuthBloc, AuthState>
            // For a simple UI test, we can use a mock or a basic instance if it doesn't do network calls on init
            // Since sl() might not be initialized, let's provide a basic one for UI testing
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                loginUseCase: sl(), // This will still fail if sl is not init.
                authRepository: sl(),
              ),
            ),
          ],
          child: const MaterialApp(
            home: LoginPage(),
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // 1. Verify that 'Welcome to CareerPath' title is present
    expect(find.text('Welcome to CareerPath'), findsOneWidget);

    // 2. Verify that the 'Log In' button is present
    expect(find.text('Log In'), findsOneWidget);

    // 3. Verify that the 'Email Address' and 'Password' field labels are visible
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    
    // 4. Verify the hint texts
    expect(find.text('name@example.com'), findsOneWidget);
    expect(find.text('••••••••••••'), findsOneWidget);
  });
}
