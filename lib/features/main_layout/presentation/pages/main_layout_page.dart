import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/dependency_injection.dart';
import '../../../feed/presentation/pages/home_page.dart';
import '../../../network/presentation/pages/network_page.dart';
import '../../../jobs/presentation/pages/jobs_page.dart';
import '../../../messages/presentation/pages/messages_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../feed/presentation/pages/create_post_sheet.dart';
import '../../../feed/presentation/manager/create_post_cubit.dart';
import '../manager/navigation_cubit.dart';
import '../widgets/app_sidebar.dart';

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({super.key});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocBuilder<NavigationCubit, int>(
        builder: (context, currentIndex) {
          return Scaffold(
            drawer: const AppSidebar(),
            body: IndexedStack(
              index: currentIndex,
              children: const [
                HomePage(),
                NetworkPage(),
                SizedBox(), // Placeholder for the '+' button (FAB)
                JobsPage(),
                MessagesPage(),
                ProfilePage(),
              ],
            ),
            bottomNavigationBar: _buildBottomBar(context, currentIndex),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showCreatePostSheet(context),
              backgroundColor: AppColors.primaryDark,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int currentIndex) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: Colors.white,
      elevation: 8,
      child: SizedBox(
        height: 60.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home_rounded, 'Home', 0, currentIndex),
            _buildNavItem(context, Icons.people_rounded, 'Network', 1, currentIndex),
            SizedBox(width: 40.w), // Space for FAB
            _buildNavItem(context, Icons.work_rounded, 'Jobs', 3, currentIndex),
            _buildNavItem(context, Icons.message_rounded, 'Messages', 4, currentIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index, int currentIndex) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => context.read<NavigationCubit>().setIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryDark : AppColors.textHint,
            size: 24.sp,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryDark : AppColors.textHint,
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (_) => sl<CreatePostCubit>(),
        child: const CreatePostSheet(),
      ),
    );
  }
}
