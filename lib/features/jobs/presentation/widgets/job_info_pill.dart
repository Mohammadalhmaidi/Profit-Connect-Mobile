import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';

class JobInfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const JobInfoPill({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(right: 12.w),
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: AppColors.accentCyan.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(24.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.accentCyan, size: 18.sp),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
