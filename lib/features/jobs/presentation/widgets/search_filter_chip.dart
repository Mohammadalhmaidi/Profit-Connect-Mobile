import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';

class SearchFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;

  const SearchFilterChip({
    required this.label,
    super.key,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(right: 8.w),
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: isActive ? AppColors.primaryBlue : context.colors.surfaceMuted,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(
        color: isActive ? AppColors.primaryBlue : context.colors.inputBorder,
        width: 1.w,
      ),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: isActive ? Colors.white : context.colors.textSecondary,
        fontSize: 14.sp,
        fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
      ),
    ),
  );
}
