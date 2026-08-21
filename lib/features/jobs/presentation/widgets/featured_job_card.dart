import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';

class FeaturedJobCard extends StatefulWidget {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String logoUrl;
  final String type;
  final String workPlace;
  final String? jobId;
  final bool isVibrant;
  final bool hasMatchBadge;
  final VoidCallback? onTap;

  const FeaturedJobCard({
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.logoUrl,
    super.key,
    this.type = 'Full-time',
    this.workPlace = 'On-site',
    this.jobId,
    this.isVibrant = false,
    this.hasMatchBadge = false,
    this.onTap,
  });

  @override
  State<FeaturedJobCard> createState() => _FeaturedJobCardState();
}

class _FeaturedJobCardState extends State<FeaturedJobCard> {
  bool _isPressed = false;
  bool _isSaved = false;
  bool _isSaving = false;

  static const List<List<Color>> _gradients = [
    [Color(0xFF7B39FD), Color(0xFF3A0051)],
    [Color(0xFF185ADB), Color(0xFF0B1033)],
    [Color(0xFF00B4D8), Color(0xFF0E3A4A)],
  ];

  List<Color> get _gradient => _gradients[widget.isVibrant ? 0 : 1];

  Future<void> _toggleSaved() async {
    if (_isSaving) return;
    final jobId = widget.jobId;
    if (jobId == null || jobId.isEmpty) {
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('jobs.save_failed'),
      );
      return;
    }
    final api = sl<ApiService>();
    final previous = _isSaved;
    setState(() {
      _isSaving = true;
      _isSaved = !_isSaved;
    });
    try {
      if (_isSaved) {
        await api.saveJob(jobId);
      } else {
        await api.unsaveJob(jobId);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaved = previous);
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('jobs.save_failed'),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) =>
      GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _isPressed ? 0.96 : 1.0,
              duration: 100.ms,
              curve: Curves.easeInOut,
              child: Container(
                width: 320.w,
                margin: EdgeInsetsDirectional.only(end: 16.w),
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _gradient,
                  ),
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: _gradient.last.withValues(alpha: 0.35),
                      blurRadius: 18.r,
                      offset: Offset(0, 8.r),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Hero(
                          tag: 'job-logo-${widget.jobId ?? '${widget.logoUrl}-${widget.company}'}',
                          child: Container(
                            width: 52.w,
                            height: 52.w,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(9.w),
                              child: CachedNetworkImage(
                                imageUrl: widget.logoUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
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
                        IconButton(
                          onPressed: _toggleSaved,
                          icon: Icon(
                            _isSaved ? Icons.bookmark : Icons.bookmark_border,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                          tooltip: context.tr('save'),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    if (widget.hasMatchBadge) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accentCyan,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          context.tr('jobs.high_match'),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                    Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '${widget.company} • ${widget.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 14.sp,
                      ),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _buildBadge(widget.salary),
                        if (widget.workPlace == 'Remote')
                          _buildBadge(context.tr('remote')),
                        _buildBadge(_typeLabel()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
          .animate()
          .fadeIn(duration: 600.ms, curve: Curves.easeOut)
          .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOut);

  String _typeLabel() => switch (widget.type) {
    'Full-time' => context.tr('full_time'),
    'Part-time' => context.tr('part_time'),
    'Contract' => context.tr('contract'),
    'Internship' => context.tr('internship'),
    _ => widget.type,
  };

  Widget _buildBadge(String label) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.18),
      borderRadius: BorderRadius.circular(12.r),
    ),
    child: Text(
      label,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
