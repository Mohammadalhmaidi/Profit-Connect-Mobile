import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/presentation/manager/theme_bloc.dart';
import '../../../../core/presentation/widgets/current_user_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(Icons.person_outline, 'My Profile', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.profile);
                }),
                _buildNavItem(Icons.notifications_none, 'Notifications', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.notifications);
                }),
                _buildNavItem(Icons.settings_outlined, 'Settings', () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.settings);
                }),
                const Divider(),
                BlocBuilder<ThemeBloc, ThemeState>(
                  builder: (context, state) {
                    final isDark = state.themeMode == ThemeMode.dark;
                    return SwitchListTile(
                      secondary: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: AppColors.textPrimary,
                      ),
                      title: Text('Dark Mode',
                          style: TextStyle(fontSize: 16.sp)),
                      value: isDark,
                      onChanged: (_) =>
                          context.read<ThemeBloc>().toggleTheme(),
                      activeColor: AppColors.vibrantPurple,
                    );
                  },
                ),
                _buildNavItem(Icons.help_outline, 'Help & Support', () {}),
              ],
            ),
          ),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthSuccess ? state.user : null;
        final title = user?.headline?.isNotEmpty == true
            ? user!.headline!
            : user?.role.name ?? '';
        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 24.h),
          decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CurrentUserAvatar(radius: 35),
              SizedBox(height: 16.h),
              Text(user?.fullName ?? 'Guest',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold)),
              Text(title,
                  style: TextStyle(color: Colors.white70, fontSize: 14.sp)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 24.sp),
      title:
          Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: InkWell(
        onTap: () {
          context.read<AuthBloc>().add(LogoutRequested());
          Navigator.pushNamedAndRemoveUntil(
              context, AppRouter.login, (route) => false);
        },
        child: Row(
          children: [
            const Icon(Icons.logout, color: AppColors.logoutRed),
            SizedBox(width: 12.w),
            const Text('Logout',
                style: TextStyle(
                    color: AppColors.logoutRed,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
