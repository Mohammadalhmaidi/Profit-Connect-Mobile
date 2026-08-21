import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/ui_utils.dart';
import '../../../../l10n/app_localizations.dart';
import '../manager/company_bloc.dart';

class CompanyCreationPage extends StatefulWidget {
  const CompanyCreationPage({super.key});

  @override
  State<CompanyCreationPage> createState() => _CompanyCreationPageState();
}

class _CompanyCreationPageState extends State<CompanyCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedIndustry;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final parts = _locationController.text
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    context.read<CompanyBloc>().add(
      CreateCompanyEvent(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        industry: _selectedIndustry,
        website: _websiteController.text.trim(),
        location: {
          'country': parts.isEmpty ? '' : parts.last,
          'city': parts.length >= 2 ? parts[parts.length - 2] : '',
          'street': parts.length >= 3
              ? parts.sublist(0, parts.length - 2).join(', ')
              : '',
        },
      ),
    );
  }

  void _addLogo() {
    UIUtils.showSnackBar(
      context: context,
      message: context.tr('company.access_logo'),
    );
  }

  @override
  Widget build(BuildContext context) => BlocListener<CompanyBloc, CompanyState>(
    listener: (context, state) {
      if (!mounted) return;
      if (state is CompanyLoading) {
        setState(() => _isLoading = true);
      } else {
        setState(() => _isLoading = false);
      }
      if (state is CompanyCreated) {
        context.read<CompanyBloc>().add(const ResetCompanyEvent());
        Navigator.pushReplacementNamed(context, AppRouter.mainLayout);
      } else if (state is CompanyError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    },
    child: Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: context.colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          context.tr('onb.create_company'),
          style: TextStyle(
            color: context.colors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('company.setup_title'),
                style: TextStyle(
                  color: context.colors.textPrimary,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                context.tr('company.setup_subtitle'),
                style: TextStyle(
                  color: context.colors.textSecondary,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 32.h),

              // Logo
              Center(
                child: GestureDetector(
                  onTap: _addLogo,
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: context.colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: context.colors.inputBorder),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32.sp,
                          color: context.colors.textSecondary,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          context.tr('company.add_logo'),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: context.colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              _buildField(
                controller: _nameController,
                label: context.tr('company.name'),
                hint: context.tr('company.name_hint'),
                icon: Icons.business,
                validator: (v) =>
                    v?.isEmpty == true ? context.tr('company.required') : null,
              ),
              SizedBox(height: 20.h),

              _buildDropdown(
                label: context.tr('company.industry'),
                value: _selectedIndustry,
                items: _industries,
                onChanged: (v) => setState(() => _selectedIndustry = v),
              ),
              SizedBox(height: 20.h),

              _buildField(
                controller: _descriptionController,
                label: context.tr('company.description'),
                hint: context.tr('company.desc_hint'),
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
              SizedBox(height: 20.h),

              _buildField(
                controller: _websiteController,
                label: context.tr('company.website'),
                hint: context.tr('company.website_hint'),
                icon: Icons.language,
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 20.h),

              _buildField(
                controller: _locationController,
                label: context.tr('company.location'),
                hint: context.tr('company.location_hint'),
                icon: Icons.location_on_outlined,
                validator: (v) {
                  final parts = (v ?? '')
                      .split(',')
                      .map((p) => p.trim())
                      .where((p) => p.isNotEmpty)
                      .toList();
                  return parts.length < 2
                      ? context.tr('company.location_required')
                      : null;
                },
              ),
              SizedBox(height: 40.h),

              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          context.tr('onb.create_company'),
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: context.colors.textPrimary,
        ),
      ),
      SizedBox(height: 8.h),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: TextStyle(fontSize: 16.sp, color: context.colors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: context.colors.textHint, fontSize: 16.sp),
          prefixIcon: Icon(
            icon,
            color: context.colors.textSecondary,
            size: 20.sp,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 18.h,
          ),
          filled: true,
          fillColor: context.colors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: context.colors.inputBorder,
              width: 1.w,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5.w,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: context.colors.textPrimary,
        ),
      ),
      SizedBox(height: 8.h),
      DropdownButtonFormField<String>(
        initialValue: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: context.tr('company.select_industry'),
          hintStyle: TextStyle(color: context.colors.textHint, fontSize: 16.sp),
          prefixIcon: Icon(
            Icons.category_outlined,
            color: context.colors.textSecondary,
            size: 20.sp,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 18.h,
          ),
          filled: true,
          fillColor: context.colors.surface,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: context.colors.inputBorder,
              width: 1.w,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 1.5.w,
            ),
          ),
        ),
      ),
    ],
  );

  final List<String> _industries = [
    'Technology',
    'Healthcare',
    'Finance',
    'Education',
    'Consulting',
    'Manufacturing',
    'Retail',
    'Media',
    'Real Estate',
    'Transportation',
    'Energy',
    'Other',
  ];
}
