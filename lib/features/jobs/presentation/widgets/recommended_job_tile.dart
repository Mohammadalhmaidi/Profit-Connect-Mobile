import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../l10n/app_localizations.dart';

class RecommendedJobTile extends StatefulWidget {
  final String title;
  final String company;
  final String location;
  final String logoUrl;
  final List<String> tags;
  final VoidCallback? onTap;

  const RecommendedJobTile({
    required this.title,
    required this.company,
    required this.location,
    required this.logoUrl,
    required this.tags,
    super.key,
    this.onTap,
  });

  @override
  State<RecommendedJobTile> createState() => _RecommendedJobTileState();
}

class _RecommendedJobTileState extends State<RecommendedJobTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) =>
      GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _isPressed ? 0.98 : 1.0,
              duration: 100.ms,
              curve: Curves.easeInOut,
              child: Container(
                margin: EdgeInsets.only(bottom: 16.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: context.colors.surface,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: context.colors.inputBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: context.colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: CachedNetworkImage(
                          imageUrl: widget.logoUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.business, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: context.colors.textPrimary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Icon(
                                Icons.bookmark_border,
                                color: context.colors.textHint,
                                size: 22.sp,
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${widget.company} • ${widget.location}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: context.colors.textSecondary,
                              fontSize: 13.sp,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: widget.tags.map(_buildTag).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .animate()
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOut);

  String _tagLabel(String key) => switch (key) {
    'Full-time' => context.tr('full_time'),
    'Remote' => context.tr('remote'),
    'Contract' => context.tr('contract'),
    'Internship' => context.tr('internship'),
    'Part-time' => context.tr('part_time'),
    _ => key,
  };

  Widget _buildTag(String label) {
    final isCyan = label == 'Full-time' || label == 'Remote';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isCyan
            ? AppColors.accentCyan.withValues(alpha: 0.1)
            : AppColors.vibrantPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        _tagLabel(label),
        style: TextStyle(
          color: isCyan ? AppColors.accentCyan : AppColors.vibrantPurple,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
