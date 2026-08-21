import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';

class OtpInputRow extends StatelessWidget {
  final String otp;
  final int length;

  const OtpInputRow({required this.otp, super.key, this.length = 4});

  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(length, (index) {
        final isFocused = otp.length == index;
        final hasValue = otp.length > index;
        final char = hasValue ? otp[index] : '';

        return Container(
          width: 70.w,
          height: 70.w,
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isFocused || hasValue
                  ? AppColors.primaryDark
                  : context.colors.inputBorder,
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
    ),
  );
}
