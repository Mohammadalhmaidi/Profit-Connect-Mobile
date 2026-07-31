import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_router.dart';
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

  final List<String> _industries = [
    'Technology', 'Healthcare', 'Finance', 'Education',
    'Consulting', 'Manufacturing', 'Retail', 'Media',
    'Real Estate', 'Transportation', 'Energy', 'Other',
  ];

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

    context.read<CompanyBloc>().add(
      CreateCompanyEvent(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        industry: _selectedIndustry,
        website: _websiteController.text.trim(),
        location: _locationController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CompanyBloc, CompanyState>(
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
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Company',
          style: TextStyle(
            color: AppColors.textPrimary,
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
                'Set up your company profile',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Tell candidates about your company',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 32.h),

              // Logo
              Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: AppColors.fieldBackground,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.indicatorInactive),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 32.sp, color: AppColors.textSecondary),
                        SizedBox(height: 4.h),
                        Text('Add Logo',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              _buildField(
                controller: _nameController,
                label: 'Company Name',
                hint: 'e.g. TechCorp Inc.',
                icon: Icons.business,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              SizedBox(height: 20.h),

              _buildDropdown(
                label: 'Industry',
                value: _selectedIndustry,
                items: _industries,
                onChanged: (v) => setState(() => _selectedIndustry = v),
              ),
              SizedBox(height: 20.h),

              _buildField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Tell us about your company...',
                icon: Icons.description_outlined,
                maxLines: 4,
              ),
              SizedBox(height: 20.h),

              _buildField(
                controller: _websiteController,
                label: 'Website',
                hint: 'https://yourcompany.com',
                icon: Icons.language,
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 20.h),

              _buildField(
                controller: _locationController,
                label: 'Location',
                hint: 'City, Country',
                icon: Icons.location_on_outlined,
              ),
              SizedBox(height: 40.h),

              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
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
                              color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Create Company',
                          style: TextStyle(
                              fontSize: 18.sp, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
        ),
        ],
      ),
    );
  }
}

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 16.sp),
            prefixIcon:
                Icon(icon, color: AppColors.textSecondary, size: 20.sp),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            filled: true,
            fillColor: AppColors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide:
                  BorderSide(color: AppColors.indicatorInactive, width: 1.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide:
                  BorderSide(color: AppColors.primaryDark, width: 1.5.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary)),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Select industry',
            hintStyle: TextStyle(color: AppColors.textHint, fontSize: 16.sp),
            prefixIcon: Icon(Icons.category_outlined,
                color: AppColors.textSecondary, size: 20.sp),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
            filled: true,
            fillColor: AppColors.white,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide:
                  BorderSide(color: AppColors.indicatorInactive, width: 1.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide:
                  BorderSide(color: AppColors.primaryDark, width: 1.5.w),
            ),
          ),
        ),
      ],
    );
  }
}
