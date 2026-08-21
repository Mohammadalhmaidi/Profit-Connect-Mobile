import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme_colors.dart';

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    required this.icon,
    required this.title,
    super.key,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: onTap,
    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    leading: Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: context.colors.chipUnselected,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(
        icon,
        color: Theme.of(context).colorScheme.primary,
        size: 22.sp,
      ),
    ),
    title: Text(
      title,
      style: TextStyle(
        color: context.colors.textPrimary,
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
    subtitle: subtitle != null
        ? Text(
            subtitle!,
            style: TextStyle(
              color: context.colors.textSecondary,
              fontSize: 13.sp,
            ),
          )
        : null,
    trailing:
        trailing ??
        Icon(Icons.chevron_right, color: context.colors.textHint, size: 20.sp),
  );
}
