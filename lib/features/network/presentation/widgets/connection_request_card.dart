import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';

class ConnectionRequestCard extends StatelessWidget {
  final String name;
  final String role;
  final String mutualConnections;
  final String imageUrl;
  final VoidCallback onAccept;
  final VoidCallback onIgnore;

  const ConnectionRequestCard({
    required this.name,
    required this.role,
    required this.mutualConnections,
    required this.imageUrl,
    required this.onAccept,
    required this.onIgnore,
    super.key,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 12.h),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(16.r),
      border: Border.all(color: context.colors.inputBorder),
    ),
    child: Column(
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28.r,
              backgroundColor: context.colors.surfaceMuted,
              backgroundImage: NetworkImage(imageUrl),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: context.colors.textPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    role,
                    style: TextStyle(
                      color: context.colors.textSecondary,
                      fontSize: 13.sp,
                    ),
                  ),
                  Text(
                    mutualConnections,
                    style: TextStyle(
                      color: context.colors.textHint,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCyan,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  context.tr('accept'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: onIgnore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.surfaceMuted,
                  foregroundColor: context.colors.textSecondary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  context.tr('ignore'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
