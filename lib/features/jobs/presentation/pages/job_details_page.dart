import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/media_url_helper.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';
import '../../domain/entities/job_entity.dart';
import '../widgets/job_info_pill.dart';
import '../widgets/requirement_list_item.dart';

class JobDetailsPage extends StatelessWidget {
  final JobEntity? job;

  const JobDetailsPage({super.key, this.job});

  String get _title => job?.title ?? 'Job Details';
  String get _company => job?.companyName ?? '';
  String get _location => job?.location ?? '';

  String _salaryText(BuildContext context) {
    final salary = job?.salary;
    if (salary == null || (salary.min == 0 && salary.max == 0)) {
      return context.tr('jobs.salary_on_request');
    }
    return '${salary.currency} ${salary.min.toInt()} - ${salary.max.toInt()}';
  }

  String _jobTypeLabel(BuildContext context, String type) => switch (type) {
    'Full-time' => context.tr('full_time'),
    'Part-time' => context.tr('part_time'),
    'Contract' => context.tr('contract'),
    'Internship' => context.tr('internship'),
    _ => type,
  };

  String _workPlaceLabel(BuildContext context, String workPlace) =>
      workPlace == 'Remote' ? context.tr('remote') : context.tr('on_site');

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.surface,
    body: Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 20.h),
                    Text(
                      _title,
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    GestureDetector(
                      onTap: () {
                        final companyId = job?.companyId;
                        if (companyId == null || companyId.isEmpty) {
                          UIUtils.showSnackBar(
                            context: context,
                            message: context.tr('jobs.company_unavailable'),
                          );
                          return;
                        }
                        Navigator.pushNamed(
                          context,
                          '/company-profile',
                          arguments: companyId,
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              _company,
                              style: TextStyle(
                                color: AppColors.accentCyan,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.accentCyan,
                              ),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            color: AppColors.accentCyan,
                            size: 18.sp,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (_location.isNotEmpty) ...[
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: context.colors.textHint,
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            _location,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 24.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          JobInfoPill(
                            icon: Icons.payments_outlined,
                            label: _salaryText(context),
                          ),
                          JobInfoPill(
                            icon: Icons.work_outline,
                            label: job?.type == null
                                ? context.tr('full_time')
                                : _jobTypeLabel(context, job!.type),
                          ),
                          JobInfoPill(
                            icon: Icons.schedule,
                            label: job?.workPlace == null
                                ? context.tr('on_site')
                                : _workPlaceLabel(context, job!.workPlace),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        _buildInfoCard(
                          context,
                          context.tr('jobs.level_label'),
                          job?.workLevel ?? 'N/A',
                        ),
                        SizedBox(width: 16.w),
                        _buildInfoCard(
                          context,
                          context.tr('jobs.status_label'),
                          job?.status ?? context.tr('jobs.open'),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      context.tr('jobs.about_title'),
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      (job?.description.isNotEmpty ?? false)
                          ? job!.description
                          : context.tr('jobs.no_description'),
                      style: TextStyle(
                        color: context.colors.textSecondary,
                        fontSize: 15.sp,
                        height: 1.6,
                      ),
                    ),
                    SizedBox(height: 32.h),
                    Text(
                      context.tr('jobs.requirements_title'),
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    if (job?.requirements.isNotEmpty ?? false)
                      ...job!.requirements.map(
                        (r) => RequirementListItem(text: r),
                      )
                    else
                      RequirementListItem(
                        text: context.tr('jobs.no_requirements'),
                      ),
                    SizedBox(height: 32.h),
                    Text(
                      context.tr('location'),
                      style: TextStyle(
                        color: context.colors.textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _buildLocationSection(context),
                    SizedBox(height: 120.h),
                  ],
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: _buildApplyButton(context),
        ),
        _buildTopNav(context),
      ],
    ),
  );

  Widget _buildHeader() {
    final logoUrl = MediaUrlHelper.resolve(job?.companyLogo);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF004D40), Color(0xFF00897B)],
            ),
          ),
        ),
        PositionedDirectional(
          bottom: -40.h,
          start: 24.w,
          child: Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white, width: 4.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: logoUrl.isEmpty
                ? Center(
                    child: Icon(
                      Icons.token,
                      color: const Color(0xFF004D40),
                      size: 40.sp,
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),
                    child: Image.network(
                      logoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(
                          Icons.token,
                          color: const Color(0xFF004D40),
                          size: 40.sp,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopNav(BuildContext context) => Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: EdgeInsets.only(
        top: ScreenUtil().statusBarHeight,
        left: 8.w,
        right: 8.w,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Widget _buildInfoCard(BuildContext context, String label, String value) =>
      Expanded(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: context.colors.inputBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: context.colors.textHint,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                value,
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildLocationSection(BuildContext context) => Container(
    height: 180.h,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Theme.of(context).brightness == Brightness.dark
          ? context.colors.surfaceMuted
          : const Color(0xFFE0F2F1),
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.location_on, color: AppColors.accentCyan, size: 40.sp),
          if (_location.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              _location,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    ),
  );

  Widget _buildApplyButton(BuildContext context) => Container(
    padding: EdgeInsets.all(24.w),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          context.colors.surface.withValues(alpha: 0),
          context.colors.surface,
        ],
      ),
    ),
    child: SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton.icon(
        onPressed: () async {
          final jobId = job?.id;
          if (jobId == null || jobId.isEmpty) {
            UIUtils.showSnackBar(
              context: context,
              message: context.tr('jobs.apply_failed'),
            );
            return;
          }
          try {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['pdf', 'doc', 'docx'],
            );
            final path = result?.files.single.path;
            if (path == null) return;
            await sl<ApiService>().applyJob(jobId, resumePath: path);
            if (!context.mounted) return;
            UIUtils.showSnackBar(
              context: context,
              message: context.tr('jobs.applied_to', {'title': _title}),
              isError: false,
            );
          } catch (_) {
            if (!context.mounted) return;
            UIUtils.showSnackBar(
              context: context,
              message: context.tr('jobs.apply_error'),
            );
          }
        },
        icon: Icon(Icons.bolt, color: Colors.white, size: 24.sp),
        label: Text(
          context.tr('jobs.easy_apply'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentCyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: 0,
        ),
      ),
    ),
  );
}
