import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A professional skeleton loader for Job Cards.
///
/// Optimized for performance by:
/// 1. Using [const] constructors to reduce widget rebuilds.
/// 2. Isolating the [Shimmer] effect to internal elements only.
/// 3. Breaking the UI into granular, reusable stateless widgets.
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 16.h),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.03),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Shimmer.fromColors(
      baseColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[700]!
          : Colors.grey[300]!,
      highlightColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.grey[600]!
          : Colors.grey[100]!,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_SkeletonHeader(), _SkeletonFooter()],
      ),
    ),
  );
}

/// A internal reusable component for building skeleton shapes.
class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double? borderRadius;

  const _SkeletonBox({
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Colors.white, // Required for Shimmer masking
      borderRadius: BorderRadius.circular(borderRadius ?? 4.r),
    ),
  );
}

class _SkeletonHeader extends StatelessWidget {
  const _SkeletonHeader();

  @override
  Widget build(BuildContext context) => Row(
    children: [
      // Company Logo Placeholder
      _SkeletonBox(width: 52.w, height: 52.w, borderRadius: 12.r),
      SizedBox(width: 12.w),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title Bar
            _SkeletonBox(width: 160.w, height: 18.h),
            SizedBox(height: 8.h),
            // Company Name/Location Bar
            _SkeletonBox(width: 100.w, height: 12.h),
          ],
        ),
      ),
    ],
  );
}

class _SkeletonFooter extends StatelessWidget {
  const _SkeletonFooter();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: 18.h),
    child: Row(
      children: [
        // Employment Type Tag Placeholder
        _SkeletonBox(width: 75.w, height: 26.h, borderRadius: 8.r),
        SizedBox(width: 8.w),
        // Salary/Experience Tag Placeholder
        _SkeletonBox(width: 85.w, height: 26.h, borderRadius: 8.r),
      ],
    ),
  );
}
