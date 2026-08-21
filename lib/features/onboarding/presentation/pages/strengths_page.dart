import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';

class StrengthsPage extends StatefulWidget {
  const StrengthsPage({super.key});

  @override
  State<StrengthsPage> createState() => _StrengthsPageState();
}

class _StrengthsPageState extends State<StrengthsPage> {
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

  final Set<String> _selectedSkills = <String>{};
  bool _isSaving = false;

  void _toggleSkill(String skill) {
    setState(() {
      if (_selectedSkills.contains(skill)) {
        _selectedSkills.remove(skill);
      } else {
        _selectedSkills.add(skill);
      }
    });
  }

  Future<void> _continue() async {
    if (_selectedSkills.length < 3 || _isSaving) return;
    setState(() => _isSaving = true);
    try {
      await sl<ApiService>().updateProfile({
        'skills': _selectedSkills.toList(),
      });
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.mainLayout);
    } catch (_) {
      if (!mounted) return;
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('onb.save_failed'),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            _buildProgressDots(context),
            SizedBox(height: 40.h),
            Text(
              context.tr('onb.strengths_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              context.tr('onb.strengths_subtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textSecondary,
                fontSize: 16.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 32.h),
            _buildSearchBar(context),
            SizedBox(height: 32.h),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 12.w,
                  runSpacing: 16.h,
                  alignment: WrapAlignment.center,
                  children: _allSkills
                      .map((s) => _buildSkillChip(context, s))
                      .toList(),
                ),
              ),
            ),
            _buildContinueButton(context),
          ],
        ),
      ),
    ),
  );

  Widget _buildProgressDots(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: List.generate(5, (index) {
      final isActive = index == 2;
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        width: isActive ? 30.w : 8.w,
        height: 8.h,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.indicatorActive
              : context.colors.inputBorder,
          borderRadius: BorderRadius.circular(4.r),
        ),
      );
    }),
  );

  Widget _buildSearchBar(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w),
    decoration: BoxDecoration(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(30.r),
      border: Border.all(
        color: context.colors.inputBorder.withValues(alpha: 0.5),
      ),
    ),
    child: TextField(
      style: TextStyle(color: context.colors.textPrimary),
      decoration: InputDecoration(
        hintText: context.tr('onb.skills_search'),
        hintStyle: TextStyle(color: context.colors.textHint, fontSize: 14.sp),
        prefixIcon: Icon(
          Icons.search,
          color: context.colors.textSecondary,
          size: 20.sp,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(vertical: 15.h),
      ),
    ),
  );

  Widget _buildSkillChip(BuildContext context, String skill) {
    final isSelected = _selectedSkills.contains(skill);
    return GestureDetector(
      onTap: () => _toggleSkill(skill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentCyan
              : context.colors.chipUnselected,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              skill,
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
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

  Widget _buildContinueButton(BuildContext context) {
    final isEnabled = _selectedSkills.length >= 3 && !_isSaving;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: isEnabled ? _continue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            disabledBackgroundColor: AppColors.primaryDark.withValues(
              alpha: 0.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
            elevation: 0,
          ),
          child: _isSaving
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      context.tr('continue'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    const Icon(Icons.arrow_forward, color: Colors.white),
                  ],
                ),
        ),
      ),
    );
  }
}
