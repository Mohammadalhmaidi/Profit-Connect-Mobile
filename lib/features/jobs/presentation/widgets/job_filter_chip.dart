import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme_colors.dart';

class JobFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final bool hasDropdown;

  const JobFilterChip({
    required this.label,
    super.key,
    this.isActive = false,
    this.hasDropdown = true,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(right: 8.w),
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    decoration: BoxDecoration(
      color: isActive ? const Color(0xFF7B39FD) : context.colors.surfaceMuted,
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : context.colors.textPrimary,
            fontSize: 14.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        if (hasDropdown) ...[
          SizedBox(width: 4.w),
          Icon(
            Icons.keyboard_arrow_down,
            color: isActive ? Colors.white : context.colors.textPrimary,
            size: 18.sp,
          ),
        ],
      ],
    ),
  );
}
