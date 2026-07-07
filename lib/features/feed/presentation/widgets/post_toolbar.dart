import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class PostToolbar extends StatelessWidget {
  const PostToolbar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.indicatorInactive, width: 0.5.w),
        ),
      ),
      child: Row(
        children: [
          _buildToolbarIcon(Icons.image_outlined, 'Image'),
          _buildToolbarIcon(Icons.description_outlined, 'Document'),
          Container(
            height: 24.h,
            width: 1.w,
            color: AppColors.indicatorInactive,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
          ),
          _buildToolbarIcon(Icons.more_horiz, 'More'),
        ],
      ),
    );
  }

  Widget _buildToolbarIcon(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        margin: EdgeInsets.only(right: 12.w),
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: AppColors.fieldBackground.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 22.sp,
        ),
      ),
    );
  }
}
