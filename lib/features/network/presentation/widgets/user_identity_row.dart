import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../l10n/app_localizations.dart';

/// صف هوية مستخدم مشترك (صورة + اسم + عنوان وظيفي + عناصر إضافية اختيارية)
/// يوحّد عرض المستخدمين في قوائم المتابعين والبحث والمقترحات.
class UserIdentityRow extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String headline;
  final String? headlineFallback;
  final Widget? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final double avatarRadius;
  final double gap;

  const UserIdentityRow({
    required this.avatarUrl,
    required this.name,
    required this.headline,
    super.key,
    this.headlineFallback,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.avatarRadius = 26,
    this.gap = 12,
  });

  /// بناء الصف من خريطة مستخدم خام (كما يعيدها الباك).
  factory UserIdentityRow.fromUserJson(
    Map<String, dynamic> user, {
    String? headlineFallback,
    Widget? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final profile = user['profile'] as Map<String, dynamic>? ?? {};
    final name = [
      profile['firstName'],
      profile['lastName'],
    ].whereType<String>().where((s) => s.isNotEmpty).join(' ');
    final headline = (profile['headline'] as String?) ?? '';
    final avatar = MediaUrlHelper.resolve((profile['avatar'] as String?) ?? '');
    return UserIdentityRow(
      avatarUrl: avatar,
      name: name,
      headline: headline,
      headlineFallback: headlineFallback,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final row = Row(
      children: [
        CircleAvatar(
          radius: avatarRadius.r,
          backgroundColor: context.colors.surfaceMuted,
          backgroundImage: avatarUrl.isNotEmpty
              ? CachedNetworkImageProvider(avatarUrl)
              : null,
          child: avatarUrl.isEmpty
              ? Icon(
                  Icons.person,
                  color: context.colors.textHint,
                  size: avatarRadius.sp,
                )
              : null,
        ),
        SizedBox(width: gap.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? context.tr('network.member') : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15.sp,
                  color: context.colors.textPrimary,
                ),
              ),
              if (headline.isNotEmpty || headlineFallback != null) ...[
                SizedBox(height: 2.h),
                Text(
                  headline.isNotEmpty ? headline : (headlineFallback ?? ''),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
              if (subtitle != null) ...[SizedBox(height: 2.h), subtitle!],
            ],
          ),
        ),
        if (trailing != null) ...[SizedBox(width: 8.w), trailing!],
      ],
    );
    if (onTap == null) return row;
    return InkWell(onTap: onTap, child: row);
  }
}
