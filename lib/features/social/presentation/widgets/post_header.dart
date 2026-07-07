import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class PostHeader extends StatelessWidget {
  const PostHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=jane'),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Jane Doe',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '• 2nd',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 14.sp,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Senior Product Designer at TechFlow',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '2h ago • ',
                      style: TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12.sp,
                      ),
                    ),
                    Icon(
                      Icons.public,
                      size: 14.sp,
                      color: AppColors.textHint,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.add, size: 18.sp),
            label: const Text('Connect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonLightPurple,
              foregroundColor: AppColors.primaryDark,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              textStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
