import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

class ProfileFormPage extends StatelessWidget {
  const ProfileFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Step 1 of 3',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildProgressIndicator(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.h),
                  Text(
                    'Build your profile',
                    style: TextStyle(color: AppColors.textPrimary, fontSize: 32.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Help recruiters and peers find you by starting with the basics.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp, height: 1.4),
                  ),
                  SizedBox(height: 40.h),
                  _buildInputField(label: 'Full Name', hint: 'Jane Doe', icon: Icons.person_outline),
                  SizedBox(height: 24.h),
                  _buildInputField(label: 'Education', hint: 'Select University or Degree', icon: Icons.school_outlined, isDropdown: true),
                  SizedBox(height: 24.h),
                  _buildInputField(label: 'Current Role', hint: 'e.g. Product Designer', icon: Icons.work_outline),
                ],
              ),
            ),
          ),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Stack(
      children: [
        Container(height: 6.h, width: double.infinity, color: AppColors.progressBackground),
        Container(
          height: 6.h,
          width: 0.33.sw,
          decoration: BoxDecoration(
            color: AppColors.accentCyan,
            borderRadius: BorderRadius.only(topRight: Radius.circular(3.r), bottomRight: Radius.circular(3.r)),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({required String label, required String hint, required IconData icon, bool isDropdown = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(color: AppColors.fieldBackground, borderRadius: BorderRadius.circular(30.r)),
          child: TextField(
            readOnly: isDropdown,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.textHint, fontSize: 16.sp),
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Icon(icon, color: AppColors.textSecondary, size: 24.sp),
              ),
              suffixIcon: isDropdown ? Padding(padding: EdgeInsets.only(right: 16.w), child: Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary)) : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 18.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
            elevation: 0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Next', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              SizedBox(width: 8.w),
              const Icon(Icons.arrow_forward, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
