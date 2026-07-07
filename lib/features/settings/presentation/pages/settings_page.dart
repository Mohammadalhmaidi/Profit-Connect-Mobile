import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/manager/app_settings_cubit.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsCubit, AppSettingsState>(
      builder: (context, state) {
        final isArabic = state.locale.languageCode == 'ar';
        
        return Scaffold(
          backgroundColor: AppColors.backgroundAlt,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                isArabic ? Icons.arrow_back_ios_new : Icons.arrow_back_ios, 
                color: Colors.black
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              isArabic ? 'الإعدادات' : 'Settings',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  margin: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35.r,
                        backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=me'),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isArabic ? 'محمد الحميدي' : 'Mohammad Al-Hmaidi',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'mohammad@careerpath.com',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                _buildSectionHeader(isArabic ? 'الحساب والأمان' : 'ACCOUNT & SECURITY'),
                _buildSectionCard([
                  SettingsTile(
                    icon: Icons.person_outline,
                    title: isArabic ? 'المعلومات الشخصية' : 'Personal Information',
                    subtitle: isArabic ? 'الاسم، البريد، والمهنة' : 'Name, email, and occupation',
                  ),
                  SettingsTile(
                    icon: Icons.lock_outline,
                    title: isArabic ? 'تسجيل الدخول والأمان' : 'Login & Security',
                  ),
                ]),

                _buildSectionHeader(isArabic ? 'تفضيلات التطبيق' : 'APP PREFERENCES'),
                _buildSectionCard([
                  SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: isArabic ? 'الوضع الليلي' : 'Dark Mode',
                    trailing: Switch.adaptive(
                      value: state.themeMode == ThemeMode.dark,
                      onChanged: (val) => context.read<AppSettingsCubit>().toggleTheme(),
                      activeColor: AppColors.primaryDark,
                    ),
                  ),
                  SettingsTile(
                    icon: Icons.language_outlined,
                    title: isArabic ? 'اللغة' : 'Language',
                    subtitle: isArabic ? 'العربية' : 'English',
                    trailing: TextButton(
                      onPressed: () {
                        final newLang = isArabic ? 'en' : 'ar';
                        context.read<AppSettingsCubit>().setLocale(newLang);
                      },
                      child: Text(isArabic ? 'English' : 'العربية'),
                    ),
                  ),
                ]),

                // Logout Button
                Padding(
                  padding: EdgeInsets.all(24.w),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logoutRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isArabic ? 'تسجيل الخروج' : 'Log Out',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Text(
          title,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> tiles) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: tiles,
      ),
    );
  }
}
