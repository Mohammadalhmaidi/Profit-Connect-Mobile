import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class SharePostSheet extends StatelessWidget {
  const SharePostSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.indicatorInactive,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 24.h),
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share this post',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            // Quick Actions
            _buildActionItem(
              icon: Icons.edit_note_outlined,
              title: 'Repost with thoughts',
              subtitle: 'Share to your feed with a caption',
            ),
            _buildActionItem(
              icon: Icons.repeat,
              title: 'Instant Repost',
              subtitle: 'Instantly share to your feed',
            ),
            _buildActionItem(
              icon: Icons.link,
              title: 'Copy Link',
              subtitle: 'Paste anywhere to share',
            ),
            Divider(color: AppColors.progressBackground, height: 40.h),
            // Search Connections
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'SEND VIA MESSAGE',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: AppColors.fieldBackground,
                borderRadius: BorderRadius.circular(30.r),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search connections...',
                  hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
                  prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            // Connections List
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: 300.h),
              child: ListView(
                shrinkWrap: true,
                children: [
                  _buildConnectionItem(
                    name: 'Sarah Chen',
                    role: 'Product Manager @ TechCorp',
                    statusColor: Colors.green,
                  ),
                  _buildConnectionItem(
                    name: 'David Miller',
                    role: 'Talent Acquisition Lead',
                    statusColor: Colors.transparent,
                  ),
                  _buildConnectionItem(
                    name: 'Jessica Wong',
                    role: 'Senior UX Designer',
                    statusColor: Colors.orange,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View all connections',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem({required IconData icon, required String title, required String subtitle}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.chipUnselected,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primaryDark, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textHint),
        ],
      ),
    );
  }

  Widget _buildConnectionItem({required String name, required String role, required Color statusColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.indicatorInactive,
                child: Icon(Icons.person, color: Colors.white),
              ),
              if (statusColor != Colors.transparent)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.w),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              minimumSize: Size(70.w, 36.h),
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
            ),
            child: Text(
              'Send',
              style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
