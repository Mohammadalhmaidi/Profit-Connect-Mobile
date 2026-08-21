import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = info.version);
      }
    } catch (_) {
      // Version unavailable - leave blank
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(title: Text(context.tr('about'))),
    body: ListView(
      padding: EdgeInsets.all(24.w),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 92.w,
                height: 92.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF005548), Color(0xFF00897B)],
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: Icon(
                  Icons.work_outline,
                  color: Colors.white,
                  size: 44.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                context.tr('app_name'),
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                context.tr('about.tagline'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 14.sp,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
              if (_version.isNotEmpty)
                Text(
                  '${context.tr('about.version')} $_version',
                  style: TextStyle(
                    color: context.colors.textHint,
                    fontSize: 13.sp,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: 28.h),
        _sectionCard(context, [
          _infoRow(
            context,
            Icons.account_balance_outlined,
            context.tr('about.company_name'),
          ),
          _infoRow(context, Icons.public, context.tr('about.website')),
          _infoRow(
            context,
            Icons.copyright_outlined,
            context.tr('about.copyright'),
          ),
        ]),
        SizedBox(height: 28.h),
        Center(
          child: Text(
            context.tr('about.disclaimer'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textHint,
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
        ),
      ],
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

  Widget _infoRow(BuildContext context, IconData icon, String value) =>
      ListTile(
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
          value,
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
