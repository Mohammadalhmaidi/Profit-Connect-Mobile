import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/presentation/widgets/brand_logo.dart';
import '../../../../core/presentation/widgets/custom_text_field.dart';
import '../../../../core/presentation/widgets/custom_button.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _googleSignIn.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
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
                  context.tr('welcome'),
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  context.tr('auth.welcome_subtitle'),
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 32.h),
                CustomTextField(
                  controller: _emailController,
                  label: context.tr('email'),
                  hintText: 'name@example.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('required_field');
                    }
                    final err = Validators.email(value);
                    return err == null ? null : context.tr('invalid_email');
                  },
                ),
                SizedBox(height: 24.h),
                CustomTextField(
                  controller: _passwordController,
                  label: context.tr('password'),
                  hintText: '••••••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return context.tr('required_field');
                    }
                    if (value.length < 8) {
                      return context.tr('password_too_short');
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRouter.forgotPassword),
                    child: Text(
                      context.tr('forgot_password'),
                      style: TextStyle(
                        color: context.colors.textSecondary,
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
                        ServerFailure(
                          state.message,
                          statusCode: state.statusCode,
                        ),
                      );
                    } else if (state is AuthSuccess) {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRouter.mainLayout,
                      );
                    }
                  },
                  builder: (context, state) => CustomButton(
                    label: context.tr('login'),
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
                  ),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        context.tr('auth.or_continue'),
                        style: TextStyle(
                          color: context.colors.textHint,
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
                          label: context.tr('auth.login_google'),
                          logo: Icon(
                            Icons.g_mobiledata,
                            color: context.colors.textPrimary,
                            size: 24.sp,
                          ),
                          backgroundColor: context.colors.surface,
                          foregroundColor: context.colors.textPrimary,
                          borderSide: BorderSide(
                            color: context.colors.inputBorder,
                          ),
                          onPressed: isLoading ? () {} : _handleGoogleSignIn,
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
                        context.tr('no_account'),
                        style: TextStyle(
                          color: context.colors.textSecondary,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRouter.signUp),
                      child: Text(
                        context.tr('signup'),
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
