import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:profit_connect_mobile/core/theme/app_colors.dart';
import 'package:profit_connect_mobile/core/theme/theme_colors.dart';

/// A highly reusable [CustomTextField] following 'Effective Dart' guidelines.
/// Designed to work seamlessly in both Auth and Profile modules.
class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;
  final TextInputType? keyboardType;

  const CustomTextField({
    required this.label,
    required this.hintText,
    super.key,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.readOnly = false,
    this.onTap,
    this.controller,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 8.h),
      TextFormField(
        controller: controller,
        obscureText: isPassword,
        readOnly: readOnly,
        onTap: onTap,
        validator: validator,
        autovalidateMode: autovalidateMode,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 16.sp, color: context.colors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: context.colors.textHint, fontSize: 16.sp),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: context.colors.textSecondary,
                  size: 20.sp,
                )
              : null,
          suffixIcon: suffixIcon != null
              ? Icon(
                  suffixIcon,
                  color: context.colors.textSecondary,
                  size: 20.sp,
                )
              : (readOnly && onTap != null)
              ? Icon(
                  Icons.keyboard_arrow_down,
                  color: context.colors.textSecondary,
                  size: 20.sp,
                )
              : null,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 18.h,
          ),
          filled: true,
          fillColor: context.colors.surfaceMuted,
          errorStyle: const TextStyle(height: 0.8),
          // 'const' removed below because .w runtime values are not constant
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: context.colors.inputBorder,
              width: 1.w,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.primaryDark, width: 1.5.w),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.error, width: 1.w),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(color: AppColors.error, width: 1.5.w),
          ),
        ),
      ),
    ],
  );
}
