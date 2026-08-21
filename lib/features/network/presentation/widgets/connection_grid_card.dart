import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';

class ConnectionGridCard extends StatelessWidget {
  final String name;
  final String role;
  final String imageUrl;
  final bool isOnline;

  const ConnectionGridCard({
    required this.name,
    required this.role,
    required this.imageUrl,
    super.key,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: context.colors.inputBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          children: [
            CircleAvatar(
              radius: 35.r,
              backgroundColor: context.colors.surfaceMuted,
              backgroundImage: NetworkImage(imageUrl),
            ),
            if (isOnline)
              PositionedDirectional(
                bottom: 2.h,
                end: 2.w,
                child: Container(
                  width: 14.w,
                  height: 14.w,
                  decoration: BoxDecoration(
                    color: AppColors.successGreen,
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
        SizedBox(height: 12.h),
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 4.h),
        Text(
          role,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.colors.textSecondary,
            fontSize: 12.sp,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: Icon(Icons.chat_bubble_outline, size: 14.sp),
            label: Text(
              context.tr('messages'),
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
              side: BorderSide(color: Theme.of(context).colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 8.h),
            ),
          ),
        ),
      ],
    ),
  );
}
