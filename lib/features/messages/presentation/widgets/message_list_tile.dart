import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';

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
    required this.name,
    required this.message,
    required this.time,
    super.key,
    this.imageUrl,
    this.leading,
    this.isUnread = false,
    this.isOnline = false,
    this.onTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      height: 88.h,
      decoration: BoxDecoration(
        color: isUnread
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
            : context.colors.surface,
      ),
      child: Row(
        children: [
          if (isUnread)
            Container(width: 4.w, color: AppColors.accentCyan)
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
                  backgroundColor: context.colors.surfaceMuted,
                  backgroundImage: imageUrl != null
                      ? CachedNetworkImageProvider(imageUrl!)
                      : null,
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
                        border: Border.all(
                          color: context.colors.surface,
                          width: 2.w,
                        ),
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
                    color: context.colors.textPrimary,
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
                    color: isUnread
                        ? Theme.of(context).colorScheme.primary
                        : context.colors.textSecondary,
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
            padding: EdgeInsetsDirectional.only(
              end: 16.w,
              top: 16.h,
              bottom: 16.h,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(
                    color: isUnread
                        ? AppColors.accentCyan
                        : context.colors.textHint,
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
