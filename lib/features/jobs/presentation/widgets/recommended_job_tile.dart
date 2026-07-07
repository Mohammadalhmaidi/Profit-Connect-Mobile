import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';

class RecommendedJobTile extends StatefulWidget {
  final String title;
  final String company;
  final String location;
  final String logoUrl;
  final List<String> tags;
  final VoidCallback? onTap;

  const RecommendedJobTile({
    super.key,
    required this.title,
    required this.company,
    required this.location,
    required this.logoUrl,
    required this.tags,
    this.onTap,
  });

  @override
  State<RecommendedJobTile> createState() => _RecommendedJobTileState();
}

class _RecommendedJobTileState extends State<RecommendedJobTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.fieldBackground),
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
              Hero(
                tag: 'logo-${widget.logoUrl}-${widget.company}',
                child: Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Image.network(widget.logoUrl, fit: BoxFit.contain),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${widget.company} • ${widget.location}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      children: widget.tags.map((tag) => _buildTag(tag)).toList(),
                    ),
                  ],
                ),
              ),
              Icon(Icons.bookmark_border, color: AppColors.textHint, size: 24.sp),
            ],
          ),
        ),
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
    .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Widget _buildTag(String label) {
    bool isCyan = label == 'Full-time' || label == 'Remote';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isCyan 
            ? AppColors.accentCyan.withValues(alpha: 0.1)
            : AppColors.vibrantPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isCyan ? AppColors.accentCyan : AppColors.vibrantPurple,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
