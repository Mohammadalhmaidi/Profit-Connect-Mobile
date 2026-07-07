import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/job_info_pill.dart';
import '../widgets/requirement_list_item.dart';

class JobDetailsPage extends StatelessWidget {
  const JobDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Scrollable Content
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
                        'Senior Experience Designer',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'TechFlow Solutions',
                        style: TextStyle(
                          color: AppColors.accentCyan,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.textHint, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            'San Francisco, CA (Remote)',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      // Info Pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: const [
                            JobInfoPill(icon: Icons.payments_outlined, label: '\$140k - \$185k'),
                            JobInfoPill(icon: Icons.groups_outlined, label: '124 Applicants'),
                            JobInfoPill(icon: Icons.work_outline, label: 'Full-time'),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // Level & Posted Row
                      Row(
                        children: [
                          _buildInfoCard('LEVEL', 'Senior (5+ yrs)'),
                          SizedBox(width: 16.w),
                          _buildInfoCard('POSTED', '2 days ago'),
                        ],
                      ),
                      SizedBox(height: 32.h),
                      // About Section
                      Text(
                        'About the job',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "We're looking for a Senior Product Designer to join our Core Experience team. You'll be responsible for crafting the future of our financial tools, focusing on simplicity, accessibility, and high-performance design patterns. You will collaborate closely with engineering and product leads to drive user-centric solutions.",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 15.sp,
                          height: 1.6,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      // Requirements Section
                      Text(
                        'Requirements',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      const RequirementListItem(text: '5+ years of experience in digital product design.'),
                      const RequirementListItem(text: 'Strong portfolio showcasing UX/UI skills and systems thinking.'),
                      const RequirementListItem(text: 'Proficiency in Figma and interactive prototyping tools.'),
                      const RequirementListItem(text: 'Experience working in an Agile environment with cross-functional teams.'),
                      const RequirementListItem(text: 'Deep understanding of iOS and Android design patterns.'),
                      SizedBox(height: 32.h),
                      // Location Section
                      Text(
                        'Location',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      _buildMapSection(),
                      SizedBox(height: 120.h), // Extra space for sticky button
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Fixed Bottom Button
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildApplyButton(),
          ),
          // Top Navigation Bar
          _buildTopNav(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 200.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://placeholder.com/office_background'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: -40.h,
          left: 24.w,
          child: Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: const Color(0xFF004D40), // Dark green from logo
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
            child: Center(
              child: Icon(Icons.token, color: Colors.white, size: 40.sp),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(top: ScreenUtil().statusBarHeight, left: 8.w, right: 8.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.4),
              Colors.transparent,
            ],
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
                IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
                IconButton(icon: const Icon(Icons.bookmark, color: Colors.white), onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.fieldBackground),
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
                color: AppColors.textHint,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      height: 180.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1),
        borderRadius: BorderRadius.circular(16.r),
        image: const DecorationImage(
          image: NetworkImage('https://placeholder.com/map_image'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Icon(Icons.location_on, color: AppColors.accentCyan, size: 40.sp),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white,
          ],
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(Icons.bolt, color: Colors.white, size: 24.sp),
          label: Text(
            'Easy Apply',
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
}
