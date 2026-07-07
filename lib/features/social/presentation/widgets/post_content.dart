import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class PostContent extends StatelessWidget {
  const PostContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15.sp,
                height: 1.6,
              ),
              children: [
                const TextSpan(text: 'Excited to share my latest research on '),
                TextSpan(
                  text: '#UX',
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const TextSpan(
                  text: ' accessibility in fintech applications. We found that users respond significantly better to high-contrast interfaces, improving task completion rates by 24%.\n\nAccessibility isn\'t just a compliance checklist; it\'s a core component of user experience.\n\nRead the full case study below! 👇',
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            children: [
              _buildHashtag('#Accessibility'),
              _buildHashtag('#FinTech'),
              _buildHashtag('#DesignSystem'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHashtag(String tag) {
    return Text(
      tag,
      style: TextStyle(
        color: AppColors.primaryDark,
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
