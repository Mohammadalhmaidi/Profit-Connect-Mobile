import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_linkedin/sign_in_with_linkedin.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../widgets/social_login_button.dart';
import '../bloc/auth_bloc.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  UserRole _selectedRole = UserRole.JobSeeker;
  final Set<String> _selectedSkills = {};
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  Future<void> _handleGoogleSignUp() async {
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
        ServerFailure('Google sign up failed: $e'),
      );
    }
  }

  Future<void> _handleLinkedInSignUp() async {
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
        ServerFailure('LinkedIn sign up failed: $e'),
      );
    }
  }

  final List<String> _allSkills = [
    'UI/UX Design', 'Python', 'Coding', 'Data Science', 'Marketing',
    'Public Speaking', 'Strategy', 'Project Management', 'Leadership',
    'Copywriting', 'Sales', 'Finance', 'SEO', 'React Native',
    'Photography', 'AWS', 'Flutter', 'JavaScript', 'Docker', 'Kubernetes',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    context.read<AuthBloc>().add(SignupSubmitted(
      firstName: _nameController.text.trim().split(' ').first,
      lastName: _nameController.text.trim().split(' ').length > 1
          ? _nameController.text.trim().split(' ').sublist(1).join(' ')
          : '',
      email: _emailController.text.trim(),
      password: _passwordController.text,
      role: _selectedRole.name,
      skills: _selectedSkills.toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.chipUnselected,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.person_add_rounded,
                        color: AppColors.primaryDark,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Create Account',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Join the CareerPath community',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // --- Role Selection ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'I am a...',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: _RoleCard(
                            icon: Icons.person_outline,
                            label: 'Employee',
                            isSelected: _selectedRole == UserRole.JobSeeker,
                            onTap: () => setState(() => _selectedRole = UserRole.JobSeeker),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _RoleCard(
                            icon: Icons.business_outlined,
                            label: 'Employer',
                            isSelected: _selectedRole == UserRole.Employer,
                            onTap: () => setState(() => _selectedRole = UserRole.Employer),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),

                    // --- Form Fields ---
                    _buildField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'John Doe',
                      icon: Icons.person_outline,
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                    SizedBox(height: 20.h),
                    _buildField(
                      controller: _emailController,
                      label: 'Email Address',
                      hint: 'name@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Required';
                        return Validators.email(v!);
                      },
                    ),
                    SizedBox(height: 20.h),
                    _buildField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Min 8 chars, uppercase, lowercase, number',
                      icon: Icons.lock_outline,
                      isPassword: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: Validators.password,
                    ),
                    SizedBox(height: 8.h),
                    _PasswordStrengthBar(password: _passwordController.text),
                    SizedBox(height: 12.h),
                    _buildField(
                      controller: _confirmPasswordController,
                      label: 'Confirm Password',
                      hint: 'Re-enter password',
                      icon: Icons.lock_outline,
                      isPassword: _obscureConfirm,
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      validator: (v) {
                        if (v != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    SizedBox(height: 24.h),

                    // --- Skills Selection ---
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Skills (select at least 3)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: _allSkills.map((skill) {
                        final selected = _selectedSkills.contains(skill);
                        return FilterChip(
                          label: Text(skill, style: TextStyle(fontSize: 12.sp)),
                          selected: selected,
                          onSelected: (val) {
                            setState(() {
                              val ? _selectedSkills.add(skill) : _selectedSkills.remove(skill);
                            });
                          },
                          selectedColor: AppColors.accentCyan.withValues(alpha: 0.3),
                          checkmarkColor: AppColors.primaryDark,
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 32.h),

                    // --- Submit Button ---
                    BlocConsumer<AuthBloc, AuthState>(
                      listener: (context, state) {
                        if (state is AuthFailure) {
                          setState(() => _isLoading = false);
                          SnackBarUtils.showFailure(
                            context,
                            ServerFailure(state.message, statusCode: state.statusCode),
                          );
                        } else if (state is AuthSuccess) {
                          setState(() => _isLoading = false);
                          if (state.user.role == UserRole.Employer) {
                            Navigator.pushReplacementNamed(context, AppRouter.profileCreation);
                          } else {
                            Navigator.pushReplacementNamed(context, AppRouter.mainLayout);
                          }
                        }
                      },
                      builder: (context, state) {
                        return SizedBox(
                      width: double.infinity,
                      height: 60.h,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.r),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Icon(Icons.arrow_forward, size: 20.sp),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Text(
                            'Or sign up with',
                            style: TextStyle(
                              color: AppColors.textHint,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return Column(
                          children: [
                            SocialLoginButton(
                              label: 'Sign up with Google',
                              logo: Icon(Icons.g_mobiledata, color: AppColors.textPrimary, size: 24.sp),
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.textPrimary,
                              borderSide: const BorderSide(color: AppColors.indicatorInactive),
                              onPressed: isLoading ? null : _handleGoogleSignUp,
                            ),
                            SizedBox(height: 16.h),
                            SocialLoginButton(
                              label: 'Sign up with LinkedIn',
                              logo: Icon(Icons.logo_dev, color: Colors.white, size: 20.sp),
                              backgroundColor: const Color(0xFF0077B5),
                              foregroundColor: Colors.white,
                              onPressed: isLoading ? null : _handleLinkedInSignUp,
                            ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Text(
                            'Log In',
                            style: TextStyle(
                              color: AppColors.primaryDark,
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
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 16.sp),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20.sp),
            suffixIcon: suffixIcon,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            filled: true,
            fillColor: AppColors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.indicatorInactive, width: 1.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.primaryDark, width: 1.5.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.error, width: 1.w),
            ),
          ),
        ),
      ],
    );
  }
}

class _PasswordStrengthBar extends StatelessWidget {
  final String password;
  const _PasswordStrengthBar({required this.password});

  int get _strength {
    int score = 0;
    if (password.length >= 8) score++;
    if (password.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;
    return score;
  }

  String get _label {
    final s = _strength;
    if (s <= 2) return 'Weak';
    if (s <= 4) return 'Medium';
    return 'Strong';
  }

  Color get _color {
    final s = _strength;
    if (s <= 2) return AppColors.error;
    if (s <= 4) return Colors.orange;
    return AppColors.successGreen;
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: _strength / 6,
                backgroundColor: AppColors.progressBackground,
                valueColor: AlwaysStoppedAnimation(_color),
                minHeight: 4.h,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(_label, style: TextStyle(color: _color, fontSize: 12.sp)),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentCyan.withValues(alpha: 0.15) : AppColors.fieldBackground,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.accentCyan : AppColors.indicatorInactive,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.accentCyan : AppColors.textSecondary, size: 28.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.accentCyan : AppColors.textPrimary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
