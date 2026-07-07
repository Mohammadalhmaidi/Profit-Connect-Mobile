import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class StrengthsPage extends StatefulWidget {
  const StrengthsPage({super.key});

  @override
  State<StrengthsPage> createState() => _StrengthsPageState();
}

class _StrengthsPageState extends State<StrengthsPage> {
  final List<String> _allSkills = [
    'UI/UX Design', 'Python', 'Coding', 'Data Science', 'Marketing',
    'Public Speaking', 'Strategy', 'Project Management', 'Leadership',
    'Copywriting', 'Sales', 'Finance', 'SEO', 'React Native', 'Photography', 'AWS',
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
      backgroundColor: AppColors.backgroundAlt,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              _buildProgressDots(),
              SizedBox(height: 40.h),
              Text(
                'What are your\nstrengths?',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.primaryDark, fontSize: 32.sp, fontWeight: FontWeight.bold, height: 1.2),
              ),
              SizedBox(height: 16.h),
              Text(
                'Select at least 3 skills to personalize your feed and help recruiters find you.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp, height: 1.5),
              ),
              SizedBox(height: 32.h),
              _buildSearchBar(),
              SizedBox(height: 32.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12.w,
                    runSpacing: 16.h,
                    alignment: WrapAlignment.center,
                    children: _allSkills.map((skill) => _buildSkillChip(skill)).toList(),
                  ),
                ),
              ),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        bool isActive = index == 2;
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: isActive ? 30.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: isActive ? AppColors.indicatorActive : AppColors.indicatorInactive,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        border: Border.all(color: AppColors.indicatorInactive.withValues(alpha: 0.5)),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search specific skills (e.g. Python)',
          hintStyle: TextStyle(color: AppColors.textHint, fontSize: 14.sp),
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.h),
        ),
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    bool isSelected = _selectedSkills.contains(skill);
    return GestureDetector(
      onTap: () => _toggleSkill(skill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentCyan : AppColors.chipUnselected,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              skill,
              style: TextStyle(color: AppColors.primaryDark, fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            if (isSelected) ...[
              SizedBox(width: 8.w),
              Icon(Icons.check, size: 16.sp, color: AppColors.primaryDark),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    bool isEnabled = _selectedSkills.length >= 3;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: isEnabled ? () {} : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            disabledBackgroundColor: AppColors.primaryDark.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Continue', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(width: 8.w),
              const Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
