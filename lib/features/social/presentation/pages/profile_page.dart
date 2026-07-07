import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Sarah Jenkins',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: AppColors.textPrimary),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Profile Header
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60.r,
                  backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=sarah'),
                ),
                Positioned(
                  bottom: 5.h,
                  right: 5.w,
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3.w),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Sarah Jenkins',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'SENIOR PRODUCT DESIGNER AT TECHFLOW',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, color: AppColors.textSecondary, size: 16.sp),
                SizedBox(width: 4.w),
                Text(
                  'San Francisco, CA',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                ),
                SizedBox(width: 8.w),
                Container(width: 4.w, height: 4.w, decoration: const BoxDecoration(color: AppColors.textSecondary, shape: BoxShape.circle)),
                SizedBox(width: 8.w),
                Text(
                  '500+ connections',
                  style: TextStyle(color: AppColors.primaryDark, fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // Action Buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.message, color: Colors.white, size: 18.sp),
                      label: const Text('Message'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(Icons.person_add, color: AppColors.primaryDark, size: 18.sp),
                      label: const Text('Connect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.buttonLightPurple,
                        foregroundColor: AppColors.primaryDark,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // Stats Container
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem('12', 'PROJECTS'),
                  _buildDivider(),
                  _buildStatItem('45', 'ENDORSEMENTS'),
                  _buildDivider(),
                  _buildStatItem('128', 'RECS'),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            // Sections
            _buildSectionCard(
              icon: Icons.person_outline,
              title: 'About',
              content: Text(
                'Passionate about creating human-centered digital experiences. Over 8 years of experience in SaaS and Fintech, focusing on complex design systems and user research. I strive to bridge the gap between technical constraints and user needs.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp, height: 1.5),
              ),
            ),
            SizedBox(height: 16.h),
            _buildExperienceSection(),
            SizedBox(height: 16.h),
            _buildSkillsSection(),
            SizedBox(height: 16.h),
            _buildEducationSection(),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: TextStyle(color: AppColors.primaryDark, fontSize: 20.sp, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 10.sp, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1.w, height: 30.h, color: AppColors.indicatorInactive);
  }

  Widget _buildSectionCard({required IconData icon, required String title, required Widget content}) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primaryDark, size: 24.sp),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          content,
        ],
      ),
    );
  }

  Widget _buildExperienceSection() {
    return _buildSectionCard(
      icon: Icons.work_outline,
      title: 'Experience',
      content: Column(
        children: [
          _buildExperienceItem(
            role: 'Senior Product Designer',
            company: 'TechFlow',
            period: 'Jan 2021 - Present • 3 yrs 1 mo',
            description: '• Led design for the flagship fintech dashboard, increasing user engagement by 40%.\n• Mentored 4 junior designers and established a cross-departmental design system.',
            isLast: false,
          ),
          _buildExperienceItem(
            role: 'UX Designer',
            company: 'Global Creative Agency',
            period: 'Jun 2018 - Dec 2020 • 2 yrs 7 mos',
            description: '• Delivered end-to-end mobile app designs for Fortune 500 clients in retail and healthcare.\n• Conducted over 50 usability testing sessions and translated findings into actionable UI improvements.',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceItem({
    required String role,
    required String company,
    required String period,
    required String description,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1.w, color: AppColors.indicatorInactive),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(role, style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Text(company, style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp)),
                Text(period, style: TextStyle(color: AppColors.textHint, fontSize: 12.sp)),
                SizedBox(height: 8.h),
                Text(description, style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp, height: 1.4)),
                if (!isLast) SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection() {
    return _buildSectionCard(
      icon: Icons.verified_outlined,
      title: 'Skills & Expertise',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkillCategory('DESIGN & CREATIVE', ['User Research', 'Interaction Design', 'Prototyping', 'Design Systems']),
          SizedBox(height: 16.h),
          _buildSkillCategory('TECHNICAL TOOLS', ['Figma', 'Adobe Creative Cloud', 'HTML/CSS', 'React Basics']),
          SizedBox(height: 16.h),
          _buildSkillCategory('SOFT SKILLS', ['Strategic Thinking', 'Public Speaking', 'Leadership']),
        ],
      ),
    );
  }

  Widget _buildSkillCategory(String title, List<String> skills) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: AppColors.textHint, fontSize: 11.sp, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: skills.map((skill) => _buildSkillChip(skill)).toList(),
        ),
      ],
    );
  }

  Widget _buildSkillChip(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.chipUnselected,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        label,
        style: TextStyle(color: AppColors.primaryDark, fontSize: 12.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildEducationSection() {
    return _buildSectionCard(
      icon: Icons.school_outlined,
      title: 'Education',
      content: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.chipUnselected,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.account_balance, color: AppColors.primaryDark, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Savannah College of Art and Design',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
                Text(
                  'B.F.A in Interactive Design & Game Development',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                ),
                Text(
                  'Class of 2018',
                  style: TextStyle(color: AppColors.textHint, fontSize: 12.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
