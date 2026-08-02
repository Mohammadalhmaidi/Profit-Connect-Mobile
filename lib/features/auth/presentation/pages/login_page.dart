import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_linkedin/sign_in_with_linkedin.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/presentation/widgets/brand_logo.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/custom_button.dart';
import '../../../../core/presentation/widgets/failure_display.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../widgets/social_login_button.dart';
import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _handleGoogleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        final auth = await account.authentication;
        if (auth.idToken != null) {
          if (!mounted) return;
          context.read<AuthBloc>().add(
                GoogleSignInRequested(
                  idToken: auth.idToken!,
                  email: account.email,
                  firstName: account.displayName?.split(' ').firstOrNull,
                  lastName: account.displayName?.split(' ').skip(1).join(' '),
                  avatar: account.photoUrl,
                ),
              );
        }
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarUtils.showFailure(
        context,
        ServerFailure('Google sign in failed: $e'),
      );
    }
  }

  Future<void> _handleLinkedInSignIn() async {
    try {
      final result = await SignInWithLinkedIn.signIn(
        clientId: const String.fromEnvironment('LINKEDIN_CLIENT_ID', defaultValue: ''),
        clientSecret: const String.fromEnvironment('LINKEDIN_CLIENT_SECRET', defaultValue: ''),
        redirectUri: const String.fromEnvironment('LINKEDIN_REDIRECT_URI', defaultValue: ''),
      );
      if (result.accessToken != null && result.accessToken!.isNotEmpty) {
        final profile = await SignInWithLinkedIn.getProfile(result.accessToken!);
        final email = await SignInWithLinkedIn.getEmail(result.accessToken!);
        if (!mounted) return;
        context.read<AuthBloc>().add(
              LinkedInSignInRequested(
                accessToken: result.accessToken!,
                email: email,
                firstName: profile?.firstName,
                lastName: profile?.lastName,
                avatar: profile?.profilePicture,
                headline: profile?.headline,
              ),
            );
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarUtils.showFailure(
        context,
        ServerFailure('LinkedIn sign in failed: $e'),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _googleSignIn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandLogo(width: 120),
                  SizedBox(height: 16.h),
                  Text(
                    'Welcome to Profit Connect',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Login to your account',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hintText: 'name@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email is required';
                      return Validators.email(value);
                    },
                  ),
                  SizedBox(height: 24.h),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hintText: '••••••••••••',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password is required';
                      if (value.length < 8) return 'Minimum 8 characters';
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, AppRouter.forgotPassword),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is AuthFailure) {
                        SnackBarUtils.showFailure(
                          context,
                          ServerFailure(state.message, statusCode: state.statusCode),
                        );
                      } else if (state is AuthSuccess) {
                        Navigator.pushReplacementNamed(context, AppRouter.mainLayout);
                      }
                    },
                    builder: (context, state) {
                      return CustomButton(
                        label: 'Log In',
                        isLoading: state is AuthLoading,
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  LoginSubmitted(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text,
                                  ),
                                );
                          }
                        },
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  SizedBox(height: 32.h),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;
                      return Column(
                        children: [
                          SocialLoginButton(
                            label: 'Login with Google',
                            logo: Icon(Icons.g_mobiledata, color: AppColors.textPrimary, size: 24.sp),
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.textPrimary,
                            borderSide: const BorderSide(color: AppColors.indicatorInactive),
                            onPressed: isLoading ? null : _handleGoogleSignIn,
                          ),
                          SizedBox(height: 16.h),
                          SocialLoginButton(
                            label: 'Login with LinkedIn',
                            logo: Icon(Icons.logo_dev, color: Colors.white, size: 20.sp),
                            backgroundColor: const Color(0xFF0077B5),
                            foregroundColor: Colors.white,
                            onPressed: isLoading ? null : _handleLinkedInSignIn,
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, AppRouter.signUp),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
