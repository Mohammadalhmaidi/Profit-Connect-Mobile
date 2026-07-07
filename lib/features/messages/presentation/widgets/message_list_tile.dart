import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class MessageListTile extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final String? imageUrl;
  final Widget? leading;
  final bool isUnread;
  final bool isOnline;
  final VoidCallback? onTap;
  final VoidCallback? onProfileTap;

  const MessageListTile({
    super.key,
    required this.name,
    required this.message,
    required this.time,
    this.imageUrl,
    this.leading,
    this.isUnread = false,
    this.isOnline = false,
    this.onTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 88.h,
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.primaryDark.withOpacity(0.05)
              : Colors.white,
        ),
        child: Row(
          children: [
            if (isUnread)
              Container(
                width: 4.w,
                color: AppColors.accentCyan,
              )
            else
              SizedBox(width: 4.w),
            
            SizedBox(width: 12.w),
            
            // Avatar Section - Clicking this should go to Public Profile
            GestureDetector(
              onTap: onProfileTap,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 28.r,
                    backgroundColor: AppColors.chipUnselected,
                    backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                    child: imageUrl == null ? leading : null,
                  ),
                  if (isOnline)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 14.w,
                        height: 14.w,
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2.w),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            SizedBox(width: 12.w),
            
            // Content Section
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    message,
                    style: TextStyle(
                      color: isUnread ? AppColors.primaryDark : AppColors.textSecondary,
                      fontSize: 14.sp,
                      fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Trailing Section
            Padding(
              padding: EdgeInsets.only(right: 16.w, top: 16.h, bottom: 16.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: TextStyle(
                      color: isUnread ? AppColors.accentCyan : AppColors.textHint,
                      fontSize: 12.sp,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (isUnread)
                    Container(
                      width: 10.w,
                      height: 10.w,
                      decoration: const BoxDecoration(
                        color: AppColors.accentCyan,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
