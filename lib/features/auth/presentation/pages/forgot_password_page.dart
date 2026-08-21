import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../api_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      SnackBarUtils.showError(context, context.tr('required_field'));
      return;
    }
    if (Validators.email(email) != null) {
      SnackBarUtils.showError(context, context.tr('invalid_email'));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await sl<ApiService>().forgotPassword(email);
      final map = res.data is Map ? Map<String, dynamic>.from(res.data) : null;
      final demoCode = map?['demoCode'];
      if (!mounted) return;
      final message =
          context.tr('auth.reset_sent') +
          (demoCode != null
              ? ' — ${context.tr('reset.demo_code', {'code': '$demoCode'})}'
              : '');
      SnackBarUtils.showSuccess(context, message);
      Navigator.pushNamed(context, AppRouter.resetPassword, arguments: email);
    } on DioException catch (e) {
      if (!mounted) return;
      SnackBarUtils.showFailure(context, handleDioError(e));
    } catch (_) {
      if (!mounted) return;
      SnackBarUtils.showError(context, context.tr('error'));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: context.colors.chipUnselected,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.lock_reset_rounded,
                color: AppColors.primaryDark,
                size: 32.sp,
              ),
            ),
            SizedBox(height: 32.h),
            Text(
              context.tr('auth.forgot_title'),
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              context.tr('auth.forgot_subtitle'),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 16.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 48.h),
            CustomTextField(
              label: context.tr('email'),
              hintText: 'name@example.com',
              suffixIcon: const Icon(Icons.email_outlined),
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: double.infinity,
              height: 60.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendResetCode,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  disabledBackgroundColor: AppColors.primaryDark.withValues(
                    alpha: 0.5,
                  ),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        context.tr('continue'),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
