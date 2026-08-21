import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../api_service.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../l10n/app_localizations.dart';

/// ورقة إضافة مشروع جديد (المشروع يخص المستخدم الحالي).
class CreateProjectSheet extends StatefulWidget {
  const CreateProjectSheet({super.key});

  @override
  State<CreateProjectSheet> createState() => _CreateProjectSheetState();
}

class _CreateProjectSheetState extends State<CreateProjectSheet> {
  final _api = sl<ApiService>();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillsController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();
  DateTime? _deadline;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final minB = num.tryParse(_budgetMinController.text.trim());
      final maxB = num.tryParse(_budgetMaxController.text.trim());
      await _api.createProject({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _categoryController.text.trim(),
        if (skills.isNotEmpty) 'skills': skills,
        if (minB != null || maxB != null)
          'budget': {
            if (minB != null) 'min': minB,
            if (maxB != null) 'max': maxB,
            'currency': 'USD',
          },
        if (_deadline != null) 'deadline': _deadline!.toIso8601String(),
      });
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      SnackBarUtils.showError(context, context.tr('error'));
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                context.tr('projects.add_project'),
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textPrimary,
                ),
              ),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: context.tr('projects.title_field'),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.tr('required_field')
                  : null,
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: context.tr('projects.category'),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.tr('required_field')
                        : null,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InkWell(
                    onTap: _pickDeadline,
                    borderRadius: BorderRadius.circular(12.r),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: context.tr('projects.deadline'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        _deadline == null
                            ? context.tr('projects.select_deadline')
                            : '${_deadline!.day}/${_deadline!.month}/${_deadline!.year}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: _deadline == null
                              ? context.colors.textHint
                              : context.colors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.tr('projects.description'),
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? context.tr('required_field')
                  : null,
            ),
            SizedBox(height: 12.h),
            TextFormField(
              controller: _skillsController,
              decoration: InputDecoration(
                labelText: context.tr('portfolio.create_tags'),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _budgetMinController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.tr('projects.budget_min'),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: TextFormField(
                    controller: _budgetMaxController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: context.tr('projects.budget_max'),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        context.tr('common.submit'),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
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
