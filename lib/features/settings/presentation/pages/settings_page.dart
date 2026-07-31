import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/manager/theme_bloc.dart';
import '../../../../core/presentation/manager/app_settings_cubit.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/settings_tile.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          Text(
            'APPEARANCE',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, themeState) {
                    final isDark = themeState.themeMode == ThemeMode.dark;
                    return SettingsTile(
                      icon: isDark ? Icons.dark_mode : Icons.light_mode,
                      title: 'Dark Mode',
                      trailing: Switch.adaptive(
                        value: isDark,
                        onChanged: (_) {
                          context.read<ThemeBloc>().toggleTheme();
                        },
                        activeColor: AppColors.vibrantPurple,
                      ),
                    );
                  },
                ),
                BlocBuilder<AppSettingsCubit, AppSettingsState>(
                  builder: (context, state) {
                    return SettingsTile(
                      icon: Icons.language,
                      title: 'Language',
                      subtitle: state.locale.languageCode == 'ar' ? 'العربية' : 'English',
                      onTap: () {
                        final newLang = state.locale.languageCode == 'en' ? 'ar' : 'en';
                        context.read<AppSettingsCubit>().setLocale(newLang);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'ACCOUNT',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Column(
              children: [
                SettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                ),
                SettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                ),
                SettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Privacy',
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'SUPPORT',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: const Column(
              children: [
                SettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help Center',
                ),
                SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About',
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
          Center(
            child: TextButton(
              onPressed: () {
                context.read<AuthBloc>().add(LogoutRequested());
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
              child: Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.logoutRed,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
