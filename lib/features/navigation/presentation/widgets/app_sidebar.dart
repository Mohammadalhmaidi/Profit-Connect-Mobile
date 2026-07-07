import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';

/// A professional sidebar/drawer component for the CareerPath application.
/// Follows Clean Architecture and 'Effective Dart' guidelines.
class AppSidebar extends StatelessWidget {
  const AppSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280.w,
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          const _SidebarHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              children: [
                _SidebarItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isActive: true,
                  onTap: () {
                    // Navigate to profile
                  },
                ),
                _SidebarItem(
                  icon: Icons.work,
                  label: 'Jobs',
                  onTap: () {
                    // Navigate to jobs
                  },
                ),
                _SidebarItem(
                  icon: Icons.bookmark,
                  label: 'My Items',
                  onTap: () {
                    // Navigate to saved items
                  },
                ),
                _SidebarItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {
                    // Navigate to settings
                  },
                ),
                SizedBox(height: 12.h),
                const Divider(),
                SizedBox(height: 12.h),
                const _DarkModeToggle(),
              ],
            ),
          ),
          const _LogoutButton(),
        ],
      ),
    );
  }
}

class _SidebarHeader extends StatelessWidget {
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20.h,
        bottom: 24.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            Color(0xFF3E067E), // Slightly lighter shade for gradient depth
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(3.r),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 2.w,
              ),
            ),
            child: CircleAvatar(
              radius: 40.r,
              backgroundColor: AppColors.chipUnselected,
              backgroundImage: const NetworkImage(
                'https://i.pravatar.cc/150?u=alex_rivera', // Profile image placeholder
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Alex Rivera',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Senior Product Designer',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: ListTile(
        onTap: onTap,
        dense: true,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        tileColor: isActive 
            ? AppColors.fieldBackground 
            : Colors.transparent,
        leading: Icon(
          icon,
          color: isActive ? AppColors.primaryDark : AppColors.textSecondary,
          size: 22.sp,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.primaryDark : AppColors.textPrimary,
            fontSize: 16.sp,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DarkModeToggle extends StatefulWidget {
  const _DarkModeToggle();

  @override
  State<_DarkModeToggle> createState() => _DarkModeToggleState();
}

class _DarkModeToggleState extends State<_DarkModeToggle> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Row(
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            color: AppColors.textSecondary,
            size: 22.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: _isDarkMode,
            activeColor: AppColors.primaryDark,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: InkWell(
        onTap: () {
          // Handle logout logic
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.logoutRed,
                size: 24.sp,
              ),
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
      ),
    );
  }
}
