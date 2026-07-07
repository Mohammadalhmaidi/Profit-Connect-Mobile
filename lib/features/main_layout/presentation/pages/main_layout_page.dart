import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../feed/presentation/pages/home_page.dart';
import '../../../network/presentation/pages/network_page.dart';
import '../../../jobs/presentation/pages/jobs_page.dart';
import '../../../messages/presentation/pages/messages_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../feed/presentation/pages/create_post_sheet.dart';
import '../manager/navigation_cubit.dart';
import '../widgets/app_sidebar.dart';

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({super.key});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const NetworkPage(),
      const SizedBox(), // Placeholder for the '+' button (FAB)
      const JobsPage(),
      const MessagesPage(), // Restored Messages Tab
      const ProfilePage(),
    ];

    return BlocProvider(
      create: (context) => NavigationCubit(),
      child: BlocConsumer<NavigationCubit, int>(
        listener: (context, index) {
          if (index != 2) { // Don't jump for the FAB placeholder
             _pageController.jumpToPage(index);
          }
        },
        builder: (context, currentIndex) {
          return Scaffold(
            drawer: const AppSidebar(),
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: pages,
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
      builder: (context) => const CreatePostSheet(),
    );
  }
}
