import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';

class JobResultCard extends StatefulWidget {
  final String title;
  final String company;
  final String location;
  final String logoUrl;
  final String postedTime;
  final String salary;
  final String workType;
  final String? jobId;
  final bool isSaved;
  final VoidCallback onApply;
  final VoidCallback? onTap;

  const JobResultCard({
    required this.title,
    required this.company,
    required this.location,
    required this.logoUrl,
    required this.postedTime,
    required this.salary,
    required this.workType,
    required this.onApply,
    super.key,
    this.jobId,
    this.isSaved = false,
    this.onTap,
  });

  @override
  State<JobResultCard> createState() => _JobResultCardState();
}

class _JobResultCardState extends State<JobResultCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) =>
      GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _isPressed ? 0.97 : 1.0,
              duration: 100.ms,
              curve: Curves.easeInOut,
              child: Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'job-logo-${widget.jobId ?? '${widget.logoUrl}-${widget.company}'}',
                          child: Container(
                            width: 50.w,
                            height: 50.w,
                            decoration: BoxDecoration(
                              color: context.colors.surfaceMuted,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12.r),
                              child: CachedNetworkImage(
                                imageUrl: widget.logoUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => ColoredBox(
                                  color: context.colors.surfaceMuted,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.business,
                                      color: Colors.grey,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: TextStyle(
                                  color: context.colors.textPrimary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                '${widget.company} • ${widget.location}',
                                style: TextStyle(
                                  color: context.colors.textSecondary,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          widget.isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border,
                          color: widget.isSaved
                              ? AppColors.primaryBlue
                              : context.colors.textHint,
                          size: 24.sp,
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        _buildTag(widget.workType.toUpperCase()),
                        SizedBox(width: 8.w),
                        _buildTag(widget.salary),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.tr('jobs.posted', {
                            'time': widget.postedTime,
                          }),
                          style: TextStyle(
                            color: context.colors.textHint,
                            fontSize: 12.sp,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: widget.onApply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24.w,
                              vertical: 8.h,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          child: Text(
                            context.tr('apply'),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .animate()
          .fadeIn(duration: 500.ms, curve: Curves.easeOut)
          .slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOut);

  Widget _buildTag(String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(
      color: context.colors.surfaceMuted,
      borderRadius: BorderRadius.circular(6.r),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: context.colors.textSecondary,
        fontSize: 11.sp,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
