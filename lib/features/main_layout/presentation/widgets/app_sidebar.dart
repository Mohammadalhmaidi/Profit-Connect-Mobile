import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_router.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({super.key});

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  bool _isDarkMode = false;

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
                _buildDarkModeToggle(),
                _buildNavItem(Icons.help_outline, 'Help & Support', () {}),
              ],
            ),
          ),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(24.w, 60.h, 24.w, 24.h),
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 35.r,
            backgroundImage: const NetworkImage('https://i.pravatar.cc/150?u=alex'),
          ),
          SizedBox(height: 16.h),
          Text(
            'Alex Johnson',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Product Designer',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 24.sp),
      title: Text(
        title,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDarkModeToggle() {
    return SwitchListTile(
      secondary: Icon(Icons.dark_mode_outlined, color: AppColors.textPrimary, size: 24.sp),
      title: Text(
        'Dark Mode',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
      value: _isDarkMode,
      onChanged: (value) {
        setState(() {
          _isDarkMode = value;
        });
      },
      activeColor: AppColors.vibrantPurple,
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: InkWell(
        onTap: () {
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
            Text(
              'Logout',
              style: TextStyle(
                color: AppColors.logoutRed,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
