import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/otp_input_row.dart';
import '../widgets/custom_num_pad.dart';

class VerifyIdentitySheet extends StatefulWidget {
  const VerifyIdentitySheet({super.key});

  @override
  State<VerifyIdentitySheet> createState() => _VerifyIdentitySheetState();
}

class _VerifyIdentitySheetState extends State<VerifyIdentitySheet> {
  String _otp = '';

  void _onDigitPressed(String digit) {
    if (_otp.length < 4) {
      setState(() {
        _otp += digit;
      });
    }
  }

  void _onBackspacePressed() {
    if (_otp.isNotEmpty) {
      setState(() {
        _otp = _otp.substring(0, _otp.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          // Drag Handle
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.indicatorInactive,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          // Lock Icon
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_person_outlined,
              color: AppColors.primaryDark,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 24.h),
          // Title & Subtitle
          Text(
            'Verify Identity',
            style: TextStyle(
              color: Colors.black,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16.sp,
                height: 1.4,
              ),
              children: [
                const TextSpan(text: 'We sent a code to\n'),
                TextSpan(
                  text: 'alex.m@stanford.edu',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          // OTP Input
          OtpInputRow(otp: _otp),
          SizedBox(height: 40.h),
          // Verify Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _otp.length == 4 ? () {} : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  disabledBackgroundColor: AppColors.primaryDark.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Verify & Proceed',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          // Resend Timer
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
              children: [
                const TextSpan(text: "Didn't receive it? "),
                TextSpan(
                  text: 'Resend code in 00:30',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          // Custom NumPad
          CustomNumPad(
            onDigitPressed: _onDigitPressed,
            onBackspacePressed: _onBackspacePressed,
          ),
        ],
      ),
    );
  }
}
