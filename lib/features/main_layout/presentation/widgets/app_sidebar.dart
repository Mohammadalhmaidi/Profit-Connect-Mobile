import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_router.dart';
import '../../../../core/presentation/manager/theme_bloc.dart';
import '../../../../core/presentation/widgets/current_user_avatar.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) => Drawer(
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
              _buildNavItem(
                Icons.bookmark_outline,
                context.tr('saved_posts_title'),
                () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.savedPosts);
                },
              ),
              _buildNavItem(
                Icons.photo_library_outlined,
                context.tr('portfolio'),
                () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.portfolio);
                },
              ),
              _buildNavItem(
                Icons.emoji_events_outlined,
                context.tr('leaderboard_title'),
                () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, AppRouter.leaderboard);
                },
              ),
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
                  final platform = MediaQuery.platformBrightnessOf(context);
                  final isDark =
                      state.themeMode == ThemeMode.dark ||
                      (state.themeMode == ThemeMode.system &&
                          platform == Brightness.dark);
                  return SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.textPrimary,
                    ),
                    title: Text('Dark Mode', style: TextStyle(fontSize: 16.sp)),
                    value: isDark,
                    onChanged: (_) {
                      final bloc = context.read<ThemeBloc>();
                      bloc.setDark(value: !bloc.isDark(platform));
                    },
                    activeThumbColor: AppColors.vibrantPurple,
                  );
                },
              ),
              _buildNavItem(Icons.help_outline, 'Help & Support', () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRouter.help);
              }),
            ],
          ),
        ),
        _buildLogoutButton(context),
      ],
    ),
  );

  Widget _buildHeader() => BlocBuilder<AuthBloc, AuthState>(
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
            Text(
              user?.fullName ?? 'Guest',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.white70, fontSize: 14.sp),
            ),
          ],
        ),
      );
    },
  );

  Widget _buildNavItem(IconData icon, String title, VoidCallback onTap) =>
      ListTile(
        leading: Icon(icon, color: AppColors.textPrimary, size: 24.sp),
        title: Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
        ),
        onTap: onTap,
      );

  Widget _buildLogoutButton(BuildContext context) => Padding(
    padding: EdgeInsets.all(24.w),
    child: InkWell(
      onTap: () {
        context.read<AuthBloc>().add(LogoutRequested());
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRouter.login,
          (route) => false,
        );
      },
      child: Row(
        children: [
          const Icon(Icons.logout, color: AppColors.logoutRed),
          SizedBox(width: 12.w),
          const Text(
            'Logout',
            style: TextStyle(
              color: AppColors.logoutRed,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
