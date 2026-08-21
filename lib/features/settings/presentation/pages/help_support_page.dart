import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const String _supportEmail = 'support@profitconnect.com';

  Future<void> _contactSupport() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: 'subject=Support%20Request',
    );
    final canLaunch = await canLaunchUrl(uri);
    if (canLaunch) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(title: Text(context.tr('help_support.title'))),
    body: ListView(
      padding: EdgeInsets.all(24.w),
      children: [
        _sectionHeader(context, context.tr('help_support.faq')),
        SizedBox(height: 12.h),
        _sectionCard(context, [
          _faqTile(
            context,
            context.tr('help_support.q1'),
            context.tr('help_support.a1'),
          ),
          _faqTile(
            context,
            context.tr('help_support.q2'),
            context.tr('help_support.a2'),
          ),
          _faqTile(
            context,
            context.tr('help_support.q3'),
            context.tr('help_support.a3'),
          ),
        ]),
        SizedBox(height: 24.h),
        _sectionHeader(context, context.tr('help_support.contact')),
        SizedBox(height: 12.h),
        _sectionCard(context, [
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 4.h,
            ),
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: context.colors.chipUnselected,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.email_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 22.sp,
              ),
            ),
            title: Text(
              _supportEmail,
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              context.tr('help_support.contact_hint'),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
            trailing: Icon(
              Icons.open_in_new,
              color: context.colors.textHint,
              size: 20.sp,
            ),
            onTap: _contactSupport,
          ),
        ]),
        SizedBox(height: 24.h),
        _sectionHeader(context, context.tr('help_support.community')),
        SizedBox(height: 12.h),
        _sectionCard(context, [
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 4.h,
            ),
            leading: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: context.colors.chipUnselected,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.forum_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 22.sp,
              ),
            ),
            title: Text(
              context.tr('help_support.community_title'),
              style: TextStyle(
                color: context.colors.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              context.tr('help_support.community_hint'),
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13.sp,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: context.colors.textHint,
              size: 20.sp,
            ),
            onTap: () => Navigator.pushNamed(context, AppRouter.profile),
          ),
        ]),
      ],
    ),
  );

  Widget _sectionHeader(BuildContext context, String label) => Text(
    label,
    style: TextStyle(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
      fontSize: 12.sp,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    ),
  );

  Widget _sectionCard(BuildContext context, List<Widget> children) =>
      DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(children: children),
      );

  Widget _faqTile(BuildContext context, String question, String answer) =>
      ExpansionTile(
        shape: const Border(),
        tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        leading: Icon(
          Icons.help_outline,
          color: Theme.of(context).colorScheme.primary,
          size: 22.sp,
        ),
        title: Text(
          question,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              answer,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 13.sp,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
}
