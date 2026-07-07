import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class OtpInputRow extends StatelessWidget {
  final String otp;
  final int length;

  const OtpInputRow({
    super.key,
    required this.otp,
    this.length = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        bool isFocused = otp.length == index;
        bool hasValue = otp.length > index;
        String char = hasValue ? otp[index] : '';

        return Container(
          width: 70.w,
          height: 70.w,
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isFocused || hasValue
                  ? AppColors.primaryDark
                  : AppColors.indicatorInactive,
              width: 2.w,
            ),
          ),
          child: Center(
            child: isFocused
                ? Container(
                    width: 2.w,
                    height: 30.h,
                    color: AppColors.primaryDark,
                  )
                : Text(
                    char,
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}
