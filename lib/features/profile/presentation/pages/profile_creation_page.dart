import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/custom_text_field.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({super.key});

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Step 1 of 3',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Linear Progress Bar
          Stack(
            children: [
              Container(
                height: 6.h,
                width: double.infinity,
                color: AppColors.progressBackground,
              ),
              Container(
                height: 6.h,
                width: 0.33.sw, // 1/3 progress
                decoration: BoxDecoration(
                  color: AppColors.accentCyan,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(3.r),
                    bottomRight: Radius.circular(3.r),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.h),
                  Text(
                    'Build your profile',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'Help recruiters and peers find you by starting with the basics.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16.sp,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 40.h),
                  
                  // Form Fields
                  CustomTextField(
                    label: 'Full Name',
                    hint: 'Jane Doe',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                  ),
                  SizedBox(height: 24.h),
                  
                  const CustomTextField(
                    label: 'Education',
                    hint: 'Select University or Degree',
                    prefixIcon: Icons.school_outlined,
                    isDropdown: true,
                  ),
                  SizedBox(height: 24.h),
                  
                  CustomTextField(
                    label: 'Current Role',
                    hint: 'e.g. Product Designer',
                    prefixIcon: Icons.work_outline,
                    controller: _roleController,
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
          
          // Next Button
          Padding(
            padding: EdgeInsets.only(
              left: 24.w, 
              right: 24.w, 
              bottom: 32.h,
              top: 10.h,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: () {
                  // Logic for next step
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
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
    );
  }
}
