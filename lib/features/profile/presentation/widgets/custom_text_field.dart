import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';

/// A specialized [StatelessWidget] for profile-related forms.
///
/// Uses [TextFormField] to integrate with Flutter's [Form] state
/// and [ScreenUtil] for responsive UI scaling.
class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData prefixIcon;
  final bool isDropdown;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const CustomTextField({
    required this.label,
    required this.hint,
    required this.prefixIcon,
    super.key,
    this.isDropdown = false,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 12.h),
      TextFormField(
        controller: controller,
        readOnly: isDropdown,
        validator: validator,
        style: TextStyle(fontSize: 16.sp, color: context.colors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.colors.textHint, fontSize: 16.sp),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Icon(
              prefixIcon,
              color: context.colors.textSecondary,
              size: 24.sp,
            ),
          ),
          suffixIcon: isDropdown
              ? Padding(
                  padding: EdgeInsetsDirectional.only(end: 16.w),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: context.colors.textSecondary,
                    size: 24.sp,
                  ),
                )
              : null,
          filled: true,
          fillColor: context.colors.surfaceMuted,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: const BorderSide(
              color: AppColors.primaryDark,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.r),
            borderSide: const BorderSide(color: AppColors.error),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 18.h),
        ),
      ),
    ],
  );
}
