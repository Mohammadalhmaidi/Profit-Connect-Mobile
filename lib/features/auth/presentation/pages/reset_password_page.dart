import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/error/dio_error_handler.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../api_service.dart';
import '../widgets/otp_input_row.dart';
import '../widgets/custom_num_pad.dart';
import '../widgets/custom_text_field.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  String _otp = '';
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  int _secondsRemaining = 60;
  Timer? _countdown;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdown?.cancel();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _countdown?.cancel();
    _secondsRemaining = 60;
    _countdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (timer.tick >= 60) {
        timer.cancel();
        setState(() => _secondsRemaining = 0);
      } else {
        setState(() => _secondsRemaining = 60 - timer.tick);
      }
    });
  }

  Future<void> _resendCode() async {
    if (_secondsRemaining > 0) return;
    setState(() => _isLoading = true);
    try {
      await sl<ApiService>().forgotPassword(widget.email);
      if (!mounted) return;
      setState(() => _otp = '');
      SnackBarUtils.showSuccess(context, 'A new verification code has been sent');
      _startCountdown();
    } on DioException catch (e) {
      if (!mounted) return;
      SnackBarUtils.showFailure(context, handleDioError(e));
    } catch (_) {
      if (!mounted) return;
      SnackBarUtils.showError(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onDigitPressed(String digit) {
    if (_otp.length < 4) {
      setState(() => _otp += digit);
    }
  }

  void _onBackspacePressed() {
    if (_otp.isNotEmpty) {
      setState(() => _otp = _otp.substring(0, _otp.length - 1));
    }
  }

  Future<void> _resetPassword() async {
    final newPassword = _newPasswordController.text;

    final passwordError = Validators.password(newPassword);
    if (passwordError != null) {
      SnackBarUtils.showError(context, passwordError);
      return;
    }
    if (newPassword != _confirmPasswordController.text) {
      SnackBarUtils.showError(context, 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await sl<ApiService>().resetPassword(widget.email, _otp, newPassword);
      if (!mounted) return;
      SnackBarUtils.showSuccess(context, 'Password reset successfully. Please sign in.');
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouter.login,
        (route) => false,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      SnackBarUtils.showFailure(context, handleDioError(e));
    } catch (_) {
      if (!mounted) return;
      SnackBarUtils.showError(context, 'Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.chipUnselected,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Icon(
                        Icons.lock_person_outlined,
                        color: AppColors.primaryDark,
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Verify & Reset',
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'We sent a 4-digit code to',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.email,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Center(child: OtpInputRow(otp: _otp)),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _secondsRemaining > 0
                              ? 'Resend code in ${_secondsRemaining}s'
                              : 'Didn\'t receive the code?',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14.sp,
                          ),
                        ),
                        TextButton(
                          onPressed:
                              _secondsRemaining > 0 || _isLoading ? null : _resendCode,
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      label: 'New Password',
                      hintText: 'At least 6 characters',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20.sp,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                      isPassword: _obscureNew,
                      controller: _newPasswordController,
                    ),
                    SizedBox(height: 20.h),
                    CustomTextField(
                      label: 'Confirm Password',
                      hintText: 'Re-enter your new password',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.textSecondary,
                          size: 20.sp,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                      ),
                      isPassword: _obscureConfirm,
                      controller: _confirmPasswordController,
                    ),
                    SizedBox(height: 32.h),
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _isLoading || _otp.length != 4
                            ? null
                            : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          disabledBackgroundColor:
                              AppColors.primaryDark.withValues(alpha: 0.5),
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
                                'Reset Password',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            CustomNumPad(
              onDigitPressed: _onDigitPressed,
              onBackspacePressed: _onBackspacePressed,
            ),
          ],
        ),
      ),
    );
  }
}
