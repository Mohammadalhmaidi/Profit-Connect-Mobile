import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../core/presentation/widgets/stagger_entrance.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';

class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> _applications = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final res = await sl<ApiService>().getMyApplications();
      final list = res.data['data'] as List<dynamic>? ?? [];
      if (!mounted) return;
      setState(() {
        _applications = list
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return AppColors.successGreen;
      case 'rejected':
        return AppColors.logoutRed;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.backgroundAlt,
    appBar: AppBar(
      backgroundColor: context.colors.surface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.tr('jobs.my_apps'),
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    ),
    body: _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _hasError
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 80.sp,
                  color: context.colors.textHint,
                ),
                SizedBox(height: 16.h),
                Text(
                  context.tr('jobs.load_failed'),
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 15.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                OutlinedButton(
                  onPressed: _load,
                  child: Text(context.tr('retry')),
                ),
              ],
            ),
          )
        : _applications.isEmpty
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 90.sp,
                  color: context.colors.textHint,
                ),
                SizedBox(height: 24.h),
                Text(
                  context.tr('jobs.no_apps_title'),
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  context.tr('jobs.no_apps_subtitle'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              itemCount: _applications.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) => StaggerEntrance(
                key: ValueKey('app-${_applications[index]['_id'] ?? index}'),
                index: index,
                child: _buildApplicationCard(_applications[index]),
              ),
            ),
          ),
  );

  Widget _buildApplicationCard(Map<String, dynamic> application) {
    final job = application['job'] as Map<String, dynamic>? ?? {};
    final company = job['company'] as Map<String, dynamic>? ?? {};
    final salary = job['salary'] as Map<String, dynamic>? ?? {};
    final status = application['status']?.toString() ?? 'Pending';
    final logo = MediaUrlHelper.resolve(company['logo'] as String? ?? '');
    final appliedAt = application['createdAt'] as String?;

    var salaryText = '';
    if (salary.isNotEmpty) {
      final min = salary['min'];
      final max = salary['max'];
      if (min != null && max != null) {
        salaryText = '${salary['currency'] ?? r'$'} $min-$max';
      }
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: context.colors.inputBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26.r,
            backgroundColor: context.colors.surfaceMuted,
            backgroundImage: logo.isNotEmpty ? NetworkImage(logo) : null,
            child: logo.isEmpty
                ? Icon(
                    Icons.business,
                    color: AppColors.primaryDark,
                    size: 24.sp,
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job['title']?.toString() ?? context.tr('jobs.untitled'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  company['name']?.toString() ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  [
                    job['location']?.toString() ?? '',
                    job['type']?.toString() ?? '',
                    salaryText,
                  ].where((s) => s.isNotEmpty).join(' \u2022 '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: context.colors.textHint,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: _statusColor(status),
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (appliedAt != null) ...[
                SizedBox(height: 6.h),
                Text(
                  _formatDate(context, appliedAt),
                  style: TextStyle(
                    color: context.colors.textHint,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, String iso) {
    try {
      final date = DateTime.parse(iso).toLocal();
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) return context.tr('common.today');
      if (diff.inDays == 1) return context.tr('jobs.yesterday');
      if (diff.inDays < 7) {
        return context.tr('jobs.days_ago', {'d': '${diff.inDays}'});
      }
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }
}
