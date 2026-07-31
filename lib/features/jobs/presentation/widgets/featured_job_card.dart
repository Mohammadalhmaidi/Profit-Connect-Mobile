import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';

class FeaturedJobCard extends StatefulWidget {
  final String title;
  final String company;
  final String location;
  final String salary;
  final String logoUrl;
  final bool isVibrant;
  final bool hasMatchBadge;
  final VoidCallback? onTap;

  const FeaturedJobCard({
    super.key,
    required this.title,
    required this.company,
    required this.location,
    required this.salary,
    required this.logoUrl,
    this.isVibrant = false,
    this.hasMatchBadge = false,
    this.onTap,
  });

  @override
  State<FeaturedJobCard> createState() => _FeaturedJobCardState();
}

class _FeaturedJobCardState extends State<FeaturedJobCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: 100.ms,
        curve: Curves.easeInOut,
        child: Container(
          width: 280.w,
          margin: EdgeInsets.only(right: 16.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: widget.isVibrant ? AppColors.vibrantPurple : const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Hero(
                    tag: 'logo-${widget.logoUrl}-${widget.company}',
                    child: Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(8.w),
                        child: CachedNetworkImage(
                          imageUrl: widget.logoUrl,
                          fit: BoxFit.contain,
                          placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (context, url, error) => const Icon(Icons.business, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  if (widget.hasMatchBadge)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'HIGH MATCH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '${widget.company} • ${widget.location}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14.sp,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      widget.salary,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.bookmark, color: Colors.white),
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
  }
}
