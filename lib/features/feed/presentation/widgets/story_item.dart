import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';

class StoryItem extends StatelessWidget {
  final String? imageUrl;
  final String label;
  final bool isYourStory;

  const StoryItem({
    super.key,
    this.imageUrl,
    required this.label,
    this.isYourStory = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 60.w,
                height: 60.w,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isYourStory
                      ? Border.all(color: AppColors.indicatorInactive, width: 2.w)
                      : Border.all(color: AppColors.primaryDark, width: 2.w),
                ),
                child: CircleAvatar(
                  backgroundColor: AppColors.chipUnselected,
                  backgroundImage: imageUrl != null ? CachedNetworkImageProvider(imageUrl!) : null,
                  child: isYourStory && imageUrl == null
                      ? Icon(Icons.add, color: AppColors.primaryDark, size: 24.sp)
                      : null,
                ),
              ),
              if (isYourStory && imageUrl != null)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.add, color: Colors.white, size: 12.sp),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
