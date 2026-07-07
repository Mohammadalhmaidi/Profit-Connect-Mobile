import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/skill_chip.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final List<String> _allSkills = [
    'UI/UX Design',
    'Python',
    'Coding',
    'Data Science',
    'Marketing',
    'Public Speaking',
    'Strategy',
    'Project Management',
    'Leadership',
    'Copywriting',
    'Sales',
    'Finance',
    'SEO',
    'React Native',
    'Photography',
    'AWS',
  ];

  final Set<String> _selectedSkills = {'UI/UX Design', 'Python', 'Strategy'};

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              // Progress Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIndicator(false),
                  SizedBox(width: 8.w),
                  _buildIndicator(false),
                  SizedBox(width: 8.w),
                  _buildIndicator(true, width: 30.w),
                  SizedBox(width: 8.w),
                  _buildIndicator(false),
                  SizedBox(width: 8.w),
                  _buildIndicator(false),
                ],
              ),
              SizedBox(height: 40.h),
              // Title
              Text(
                'What are your\nstrengths?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 16.h),
              // Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  'Select at least 3 skills to personalize your feed and help recruiters find you.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16.sp,
                    height: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              // Search Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search specific skills (e.g. Python)',
                    hintStyle: TextStyle(
                      color: AppColors.textHint,
                      fontSize: 14.sp,
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 15.h),
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              // Skills Wrap
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12.w,
                    runSpacing: 16.h,
                    alignment: WrapAlignment.center,
                    children: _allSkills.map((skill) {
                      return SkillChip(
                        label: skill,
                        isSelected: _selectedSkills.contains(skill),
                        onTap: () => _toggleSkill(skill),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Continue Button
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _selectedSkills.length >= 3 ? () {} : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      disabledBackgroundColor: AppColors.primaryDark.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 20.sp),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicator(bool isActive, {double? width}) {
    return Container(
      width: width ?? 8.w,
      height: 8.h,
      decoration: BoxDecoration(
        color: isActive ? AppColors.indicatorActive : AppColors.indicatorInactive,
        borderRadius: BorderRadius.circular(4.r),
      ),
    );
  }
}
