import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';

class DashboardLogo extends StatelessWidget {
  const DashboardLogo({super.key});

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 150.w,
        height: 150.w,
        decoration: BoxDecoration(
          color: AppColors.logoBackground.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(40.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentCyan.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.school, size: 80.w, color: Colors.white),
            Positioned(
              bottom: 35.h,
              right: 35.w,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: const BoxDecoration(
                  color: AppColors.accentCyan,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  'CP',
                  style: TextStyle(
                    color: AppColors.secondaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 40.h),
      Text(
        'Profit Connect',
        style: TextStyle(
          color: Colors.white,
          fontSize: 42.sp,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      SizedBox(height: 10.h),
      Text(
        'BUILDING YOUR FUTURE',
        style: TextStyle(
          color: AppColors.accentCyan,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          letterSpacing: 4,
        ),
      ),
    ],
  );
}
