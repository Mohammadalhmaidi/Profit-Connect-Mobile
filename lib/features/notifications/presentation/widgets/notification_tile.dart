import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme_colors.dart';

class NotificationTile extends StatelessWidget {
  final Widget leading;
  final InlineSpan title;
  final String time;
  final bool isUnread;
  final List<Widget>? actions;

  const NotificationTile({
    required this.leading,
    required this.title,
    required this.time,
    super.key,
    this.isUnread = false,
    this.actions,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    decoration: BoxDecoration(
      color: isUnread
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.10)
          : Colors.transparent,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Leading Icon/Avatar
        SizedBox(width: 48.w, height: 48.w, child: leading),
        SizedBox(width: 12.w),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                time,
                style: TextStyle(
                  color: context.colors.textHint,
                  fontSize: 12.sp,
                ),
              ),
              if (actions != null && actions!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Row(children: actions!),
              ],
            ],
          ),
        ),
        // Unread Dot
        if (isUnread)
          Padding(
            padding: EdgeInsets.only(top: 4.h, left: 8.w),
            child: Container(
              width: 8.w,
              height: 8.w,
              decoration: const BoxDecoration(
                color: Color(0xFF7B39FD), // Purple dot
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    ),
  );
}

class NotificationActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const NotificationActionButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(right: 8.w),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? const Color(0xFF7B39FD)
            : context.colors.surfaceMuted,
        foregroundColor: isPrimary ? Colors.white : context.colors.textPrimary,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
      ),
    ),
  );
}
