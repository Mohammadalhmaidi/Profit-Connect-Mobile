import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../api_service.dart';

class ProfileFormPage extends StatefulWidget {
  const ProfileFormPage({super.key});

  @override
  State<ProfileFormPage> createState() => _ProfileFormPageState();
}

class _ProfileFormPageState extends State<ProfileFormPage> {
  final _fullNameController = TextEditingController();
  final _headlineController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _headlineController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final fullName = _fullNameController.text.trim();
    if (fullName.isEmpty) {
      UIUtils.showSnackBar(
        context: context,
        message: context.tr('onb.name_required'),
      );
      return;
    }
    final parts = fullName.split(' ').where((p) => p.isNotEmpty).toList();
    final firstName = parts.first;
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    setState(() => _isSaving = true);
    try {
      await sl<ApiService>().updateProfile({
        'firstName': firstName,
        'lastName': lastName,
        'headline': _headlineController.text.trim(),
      });
      if (!mounted) return;
      Navigator.pushNamed(context, AppRouter.strengths);
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
    appBar: AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
        _buildProgressIndicator(context),
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
                _buildInputField(
                  context: context,
                  controller: _fullNameController,
                  label: context.tr('auth.full_name'),
                  hint: 'Jane Doe',
                  icon: Icons.person_outline,
                ),
                SizedBox(height: 24.h),
                _buildInputField(
                  context: context,
                  controller: _headlineController,
                  label: context.tr('onb.job_title'),
                  hint: 'e.g. Product Designer',
                  icon: Icons.work_outline,
                ),
              ],
            ),
          ),
        ),
        _buildNextButton(context),
      ],
    ),
  );

  Widget _buildProgressIndicator(BuildContext context) => Stack(
    children: [
      Container(
        height: 6.h,
        width: double.infinity,
        color: context.colors.surfaceMuted,
      ),
      FractionallySizedBox(
        widthFactor: 1 / 3,
        heightFactor: 1,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.accentCyan,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(3.r),
                bottomRight: Radius.circular(3.r),
              ),
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildInputField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 12.h),
      DecoratedBox(
        decoration: BoxDecoration(
          color: context.colors.surfaceMuted,
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: TextField(
          controller: controller,
          style: TextStyle(color: context.colors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: context.colors.textHint,
              fontSize: 16.sp,
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Icon(
                icon,
                color: context.colors.textSecondary,
                size: 24.sp,
              ),
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 18.h),
          ),
        ),
      ),
    ],
  );

  Widget _buildNextButton(BuildContext context) => Padding(
    padding: EdgeInsets.all(24.w),
    child: SizedBox(
      width: double.infinity,
      height: 56.h,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _next,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
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
                    context.tr('next'),
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
