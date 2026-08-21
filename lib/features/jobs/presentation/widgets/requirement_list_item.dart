import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';

class RequirementListItem extends StatelessWidget {
  final String text;

  const RequirementListItem({required this.text, super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.only(top: 2.h),
          padding: EdgeInsets.all(2.w),
          decoration: const BoxDecoration(
            color: AppColors.accentCyan,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check, color: Colors.white, size: 14.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 14.sp,
              height: 1.4,
            ),
          ),
        ),
      ],
    ),
  );
}
