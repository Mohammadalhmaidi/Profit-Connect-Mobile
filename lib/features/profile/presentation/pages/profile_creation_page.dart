import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../api_service.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/custom_text_field.dart';

class ProfileCreationPage extends StatefulWidget {
  const ProfileCreationPage({super.key});

  @override
  State<ProfileCreationPage> createState() => _ProfileCreationPageState();
}

class _ProfileCreationPageState extends State<ProfileCreationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    setState(() => _isSaving = true);
    try {
      final api = sl<ApiService>();
      final payload = <String, dynamic>{};
      final name = _nameController.text.trim();
      final role = _roleController.text.trim();
      if (name.isNotEmpty) {
        final parts = name.split(' ').where((p) => p.isNotEmpty).toList();
        if (parts.isNotEmpty) payload['firstName'] = parts.first;
        if (parts.length > 1) payload['lastName'] = parts.sublist(1).join(' ');
      }
      if (role.isNotEmpty) payload['headline'] = role;
      if (payload.isNotEmpty) {
        await api.updateProfile(payload);
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRouter.companyCreation);
    } catch (_) {
      if (!mounted) return;
      SnackBarUtils.showError(
        context,
        context.tr('profile.update_failed', {'error': ''}),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: context.colors.background,
    appBar: AppBar(
      backgroundColor: context.colors.background,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: context.colors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        context.tr('onb.step_of', {'step': '1', 'total': '3'}),
        style: TextStyle(
          color: context.colors.textSecondary,
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
              color: context.colors.surfaceMuted,
            ),
            Container(
              height: 6.h,
              width: 0.33.sw, // 1/3 progress
              decoration: BoxDecoration(
                color: AppColors.accentCyan,
                borderRadius: BorderRadiusDirectional.only(
                  topEnd: Radius.circular(3.r),
                  bottomEnd: Radius.circular(3.r),
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
                  context.tr('onb.build_title'),
                  style: TextStyle(
                    color: context.colors.textPrimary,
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  context.tr('onb.build_subtitle'),
                  style: TextStyle(
                    color: context.colors.textSecondary,
                    fontSize: 16.sp,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 40.h),

                // Form Fields
                CustomTextField(
                  label: context.tr('profile.full_name'),
                  hint: context.tr('profile.name_hint'),
                  prefixIcon: Icons.person_outline,
                  controller: _nameController,
                ),
                SizedBox(height: 24.h),

                CustomTextField(
                  label: context.tr('education'),
                  hint: context.tr('onb.select_uni'),
                  prefixIcon: Icons.school_outlined,
                  isDropdown: true,
                ),
                SizedBox(height: 24.h),

                CustomTextField(
                  label: context.tr('profile.current_role'),
                  hint: context.tr('profile.role_hint'),
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
              onPressed: _isSaving ? null : _next,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.tr('next'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_back
                        : Icons.arrow_forward,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
